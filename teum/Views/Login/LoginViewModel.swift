//
//  LoginViewModel.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import AuthenticationServices
import FirebaseAuth

final class LoginViewModel: ViewModelType {
    static let shared = LoginViewModel()
    @Published var isAuthenticated: Bool = false
    @Published var user: FirebaseAuth.User?
    private var appleSignInManager: AppleLoginManager
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // 활성화된 윈도우 씬 찾기
        var window: UIWindow?
        
        // 먼저 활성화된 씬 찾기
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene,
               scene.activationState == .foregroundActive,
               let firstWindow = windowScene.windows.first {
                window = firstWindow
                break
            }
        }
        
        // 활성화된 씬이 없으면 아무 씬이나 사용
        if window == nil,
           let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            window = windowScene.windows.first
        }
        
        self.appleSignInManager = AppleLoginManager(window: window)
        
        // 인증 상태 리스너 설정
        self.authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
        }
    }
    //리소스 정리
    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    //액션 열거형 추가
    enum Action {
        case appleLogin(ASAuthorizationAppleIDRequest)
        case appleLoginHandler(Result<ASAuthorization, Error>)
    }
    
    //인스턴스 메서드로 변경
    func send(action: Action) {
        switch action {
        case .appleLogin(let request):
            handleAppleLoginRequest(request)
        case .appleLoginHandler(let result):
            handleAppleLoginResult(result)
        }
    }
                                           
    //Apple 로그인 요청 처리
    private func handleAppleLoginRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = appleSignInManager.randomNonceString()
        appleSignInManager.currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = appleSignInManager.sha256(nonce)
    }
                                           
    //Apple 로그인 결과 처리
    private func handleAppleLoginResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = appleSignInManager.currentNonce else {
                    print("Invalid state: A login callback was received, but no login request was sent.")
                    return
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                //Firebase 인증 정보 초기화
                let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
                
                //Firebase에 로그인
                Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                    if let error = error {
                        print("Firebase sign-in error: \(error.localizedDescription)")
                        return
                    }
                    
                    //로그인 성공
                    self?.isAuthenticated = true
                    self?.user = authResult?.user

                    if let fullName = appleIDCredential.fullName,
                       let givenName = fullName.givenName,
                       let familyName = fullName.familyName {
                        let displayName = "\(givenName) \(familyName)"
                        
                        UserDefaults.standard.set(displayName, forKey: "userName")
                        print(displayName)
                        print(UserDefaults.standard.string(forKey: "userName"))
                        // 사용자 프로필 업데이트
                        let changeRequest =  Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = displayName
                        changeRequest?.commitChanges(completion: { error in
                            if let error = error {
                                print("프로필 업데이트 실패: \(error.localizedDescription)")
                            } else {
                                print("프로필 이름 업데이트 성공")
                                // 업데이트된 사용자 정보 다시 가져오기
                                Auth.auth().currentUser?.reload { error in
                                    if let error = error {
                                        print("사용자 정보 새로고침 실패: \(error)")
                                    } else {
                                        self?.user = Auth.auth().currentUser
                                    }
                                }
                            }
                        })
                    }
                }
            }
        case .failure(let error):
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }
    }
    
    //Google Login
    func loginWithGoogle() {
        GoogleLoginManager.shared.signIn { [weak self] success, error in
            if let error = error {
                print("Google 로그인 실패: \(error.localizedDescription)")
                return
            }
            
            if success {
                print("Google 로그인 성공")
            }
        }
    }
}

