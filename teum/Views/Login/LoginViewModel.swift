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
    @Published var isAuthenticated = false
    @Published var isLoading = true
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
        
        // Firebase 인증 상태 리스너 설정
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
            self?.isLoading = false
        }
        
        // 디버깅용 코드 추가
           if let currentUser = Auth.auth().currentUser {
               print("🔑 현재 로그인된 사용자: \(currentUser.uid)")
               print("📝 DisplayName: \(currentUser.displayName ?? "없음")")
               print("📧 Email: \(currentUser.email ?? "없음")")
           } else {
               print("🔒 로그인된 사용자 없음")
           }
           
           // UserDefaults 값 확인
           print("🗄️ UserDefaults userName: \(UserDefaults.standard.string(forKey: "userName") ?? "없음")")
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
        
    func withDrow() {
        // 현재 사용자 존재 확인
        guard let user = Auth.auth().currentUser else {
            print("❌ 회원 탈퇴 실패: 로그인 정보가 없습니다. 다시 로그인 해주세요.")
            return
        }
        
        // 애플 로그인으로 로그인한 경우
        if let providerID = user.providerData.first?.providerID, providerID == "apple.com" {
            // 애플 리프레시 토큰 확인
            if let token = retrieveAppleRefreshToken() {
                let clientSecret = createClientSecret()
                
                // 재인증 시도
                appleSignInManager.startSignInWithAppleFlow() // 애플 로그인 재인증
                
                // 토큰 취소 및 로그아웃
                appleSignInManager.revokeAppleToken(clientSecret: clientSecret, token: token) {
                    try? Auth.auth().signOut()
                }
            } else {
                // 토큰이 없는 경우 그냥 로그아웃
                try? Auth.auth().signOut()
            }
        } else {
            // 일반 로그아웃
            try? Auth.auth().signOut()
        }
    }
    
    func retrieveAppleRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: "appleRefreshToken")

    }
    
    func createClientSecret() -> String {
        // JWT 헤더 생성
        let header = [
            "alg": "ES256",
            "kid": APIKey.kid // Apple Developer 계정에서 가져온 키 ID
        ]
        
        // 현재 시간과 만료 시간 (10분 후)
        let currentTime = Int(Date().timeIntervalSince1970)
        let expirationTime = currentTime + 600 // 10분
        
        // JWT 페이로드 생성
        let payload = [
            "iss": APIKey.iss, // Apple Developer 팀 ID
            "iat": currentTime,
            "exp": expirationTime,
            "aud": "https://appleid.apple.com",
            "sub": Bundle.main.bundleIdentifier! // 앱 번들 ID
        ] as [String: Any]
        
        // 헤더와 페이로드를 Base64URL로 인코딩
        guard let headerData = try? JSONSerialization.data(withJSONObject: header),
              let payloadData = try? JSONSerialization.data(withJSONObject: payload),
              let headerBase64 = base64URLEncode(headerData),
              let payloadBase64 = base64URLEncode(payloadData) else {
            return ""
        }
        
        // 서명할 데이터 준비
        let toSign = "\(headerBase64).\(payloadBase64)"
        guard let dataToSign = toSign.data(using: .utf8) else { return "" }
        
        // 서명 생성 (Apple Developer 계정에서 다운로드한 p8 파일에서 추출한 개인 키 사용)
        guard let privateKey = loadPrivateKey(),
              let signature = sign(data: dataToSign, with: privateKey),
              let signatureBase64 = base64URLEncode(signature) else {
            return ""
        }
        
        // JWT 토큰 반환
        return "\(toSign).\(signatureBase64)"
    }

    // Base64URL 인코딩 (표준 Base64에서 URL 안전하게 변환)
    private func base64URLEncode(_ data: Data) -> String? {
        let base64 = data.base64EncodedString()
        let base64URL = base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return base64URL
    }

    // 개인 키 로드
    private func loadPrivateKey() -> SecKey? {
        // 앱 번들에서 p8 파일 로드
        guard let path = Bundle.main.path(forResource: "AuthKey_\(APIKey.kid)", ofType: "p8"),
              let keyData = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return nil
        }
        
        // PEM 형식에서 키 데이터 추출
        let pemString = String(data: keyData, encoding: .utf8)?
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
        
        guard let pemData = Data(base64Encoded: pemString ?? "") else {
            return nil
        }
        
        // 키 생성 파라미터
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate
        ]
        
        // SecKey 객체 생성
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(pemData as CFData,
                                                   attributes as CFDictionary,
                                                   &error) else {
            return nil
        }
        
        return privateKey
    }

    // 데이터 서명
    private func sign(data: Data, with privateKey: SecKey) -> Data? {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey,
                                                   .ecdsaSignatureMessageX962SHA256,
                                                   data as CFData,
                                                   &error) as Data? else {
            return nil
        }
        
        return signature
    }
    
    func saveAppleRefreshToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "appleRefreshToken")
    }
    
    //Apple 로그인 요청 처리
    private func handleAppleLoginRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = appleSignInManager.randomNonceString()
        appleSignInManager.currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = appleSignInManager.sha256(nonce)
    }
                                           
    //Apple 로그인 결과 처리
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
                
                // 리프레시 토큰 저장 - 이 부분 추가
                if let authorizationCode = appleIDCredential.authorizationCode,
                   let codeString = String(data: authorizationCode, encoding: .utf8) {
                    saveAppleRefreshToken(codeString)
                }
                
                //Firebase 인증 정보 초기화
                let credential = OAuthProvider.appleCredential(withIDToken: idTokenString, rawNonce: nonce, fullName: appleIDCredential.fullName)
                
                // Firebase 로그인 성공 후
                Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                    if let error = error {
                        print("로그인 실패: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let user = authResult?.user else { return }
                    
                    // 1. UserDefaults에 자주 사용하는 기본 정보 저장
                    print("나다",user.uid)
                    UserDefaultsManager.shared.userId = user.uid
                    UserDefaultsManager.shared.name = user.displayName ?? ""
                    UserDefaultsManager.shared.email = user.email ?? ""
                    //UserDefaultsManager.shared.updateUser(user.uid)
//                    UserDefaults.standard.setValue(user.uid, forKey: UserDefaultsKeys.userId)
//                    UserDefaults.standard.setValue(user.displayName, forKey: UserDefaultsKeys.name)

                    // 2. Firestore에 사용자 정보 저장 (최초 로그인 시)
                    Task {
                        do {
                            try await FireStoreManager.shared.saveUser(
                                name: user.displayName ?? "",
                                email: user.email ?? ""
                            )
                            
                            // 3. Firestore에서 완전한 사용자 정보 가져오기
                            if let firestoreUser = try await FireStoreManager.shared.fetchUser(by: user.uid) {
                                // 4. Firestore에서 가져온 정보로 UserDefaults 업데이트
                                UserDefaultsManager.shared.updateUser(firestoreUser)
                            }
                        } catch {
                            print("Firestore 사용자 정보 처리 실패: \(error)")
                        }
                    }
                    print("유저디폴트 uid",UserDefaults.standard.string(forKey: UserDefaultsKeys.userId))
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
                if let user = Auth.auth().currentUser {
                        UserDefaultsManager.shared.userId = user.uid
                        UserDefaultsManager.shared.name = user.displayName ?? ""
                        UserDefaultsManager.shared.email = user.email ?? ""
                        UserDefaultsManager.shared.profileImageURL = user.photoURL?.absoluteString ?? ""
                        
                        // Firestore 처리 추가
                        Task {
                            do {
                                try await FireStoreManager.shared.saveUser(
                                    name: user.displayName ?? "",
                                    email: user.email ?? ""
                                )
                                
                                if let firestoreUser = try await FireStoreManager.shared.fetchUser(by: user.uid) {
                                    UserDefaultsManager.shared.updateUser(firestoreUser)
                                }
                            } catch {
                                print("Firestore 사용자 정보 처리 실패: \(error)")
                            }
                        }
                    }
            }
        }
    }
}

