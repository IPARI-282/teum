//
//  GoogleLoginManager.swift
//  teum
//
//  Created by 소정섭 on 4/22/25.
//

import Foundation

import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class GoogleLoginManager {
    static let shared = GoogleLoginManager()
        
    func signIn(presenting viewController: UIViewController? = nil, completion: @escaping (Bool, Error?) -> Void) {
        //적절한 presenter 찾기
        guard let presenter = viewController ?? self.topViewController() else {
            completion(false, NSError(domain: "GoogleSignInError", code: -2, userInfo: [NSLocalizedDescriptionKey: "프레젠테이션에 필요한 화면을 찾을 수 없습니다."]))
            return
        }
        
        //Google 로그인 실행
        GIDSignIn.sharedInstance.signIn(withPresenting: presenter) { signInResult, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let signInResult = signInResult else {
                completion(false, NSError(domain: "GoogleSignInError", code: -3, userInfo: [NSLocalizedDescriptionKey: "인증 정보를 가져올 수 없습니다"]))
                return
            }
            
            guard let idToken = signInResult.user.idToken?.tokenString else {
                completion(false, NSError(domain: "GoogleSignInError", code: -3, userInfo: [NSLocalizedDescriptionKey: "ID 토큰을 가져올 수 없습니다"]))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: signInResult.user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                //Firebase 사용자 객체
                guard let firebaseUser = authResult?.user else {
                    completion(true, nil)//인증은 성공했지만 사용자 객체를 얻지 못함
                    return
                }
                //Google 프로필 정보
                let googleUser = signInResult.user
                let fullName = googleUser.profile?.name
                let photoURL = googleUser.profile?.imageURL(withDimension: 400)
                
                //Firebase 사용자 프로필 업데이트
                let changeRequest = firebaseUser.createProfileChangeRequest()
                
                if firebaseUser.displayName == nil, let name = fullName {
                    changeRequest.displayName = name
                }
                
                if firebaseUser.photoURL == nil, let photoURLString = photoURL {
                    changeRequest.photoURL = photoURLString
                }
                
                //변경사항 있을 경우에만 업데이트
                if changeRequest.displayName != nil || changeRequest.photoURL != nil {
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("프로필 업데이트 실패: \(error.localizedDescription)")
                        } else {
                            print("프로필 업데이트 성공")
                        }
                        completion(true, nil)
                    }
                } else {
                    completion(true,nil)
                }
            }
        }
    }
        
    
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        try? Auth.auth().signOut()
    }

    //최상위 뷰 컨틀롤러 찾기 (Google 로그인 UI를 표시하기 위함)
    private func topViewController() -> UIViewController? {
        //활성화된 윈도우 씬 찾기
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene,scene.activationState == .foregroundActive, let window = windowScene.windows.first {
                return self.topViewController(window.rootViewController)
                }
        }
        //대안으로 어떤 윈도우 씬이든 첫 번째 윈도우 사용
        for scene in UIApplication.shared.connectedScenes {
            if let windowScene = scene as? UIWindowScene, let window = windowScene.windows.first {
                return self.topViewController(window.rootViewController)
            }
        }
        
        return nil
    }


    private func topViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        if let navigationController = rootViewController as? UINavigationController {
            return topViewController(navigationController.visibleViewController)
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            return topViewController(tabBarController.selectedViewController)
        }
        
        if let presentedViewController = rootViewController?.presentedViewController {
            return topViewController(presentedViewController)
        }
        
        return rootViewController
    }
}
