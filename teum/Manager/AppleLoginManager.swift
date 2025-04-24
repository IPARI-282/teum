//
//  AppleLoginManager.swift
//  teum
//
//  Created by 소정섭 on 4/22/25.
//

import Foundation

import AuthenticationServices
import CryptoKit
import FirebaseCore
import FirebaseAuth

class AppleLoginManager: NSObject {
    private var continuation: CheckedContinuation<ASAuthorization, Error>?
    var currentNonce: String?
    // UIWindow 참조를 저장할 속성 추가
    private var window: UIWindow?
    
    //기본 초기화 메서드
    override init() {
        super.init()
    }
    //window 참조를 받는 초기화 메서드 추가
    init(window: UIWindow?) {
        self.window = window
        super.init()
    }
    
    func startSignIn() async throws -> ASAuthorization {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
    
    func reauthenticateUser(with appleIdToken: String, rawNonce: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        // Initialize a Firebase credential, including the user's full name.
        let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: appleIdToken, rawNonce: rawNonce)
        // Sign in with Firebase.
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (authResult, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(authResult, nil)
        })
   
    }
    
}

extension AppleLoginManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        //주입된 window가 있으면 먼저 사용
        if let window = self.window {
            return window
        }
        
        //없으면 기존 로직 실행
        // 활성화된 윈도우 씬을 찾아서 그 씬의 첫 번째 윈도우를 반환
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene,
               scene.activationState == .foregroundActive,
               let window = windowScene.windows.first {
                return window
            }
        }
        
        // 대안으로 어떤 윈도우 씬이든 첫 번째 윈도우 반환
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene,
               let window = windowScene.windows.first {
                return window
            }
        }
        
        // 정말 윈도우를 찾지 못한 경우
        print("Warning: No window found for presentation")
        return UIWindow()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // continuation을 사용하여 에러 반환
        if let continuation = self.continuation {
            self.continuation = nil
            continuation.resume(returning: authorization)
            return
        }
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetch identity token")
            return
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return
          }
            
            let credentail = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
            
            Auth.auth().signIn(with: credentail) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            print("Successfully signed in with Apple")
            }
        }
      }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // continuation을 사용하여 에러 반환
        if let continuation = self.continuation {
            self.continuation = nil
            continuation.resume(throwing: error)
            return
        }
        print("Sign in with Apple errored: \(error)")    }
    
}

