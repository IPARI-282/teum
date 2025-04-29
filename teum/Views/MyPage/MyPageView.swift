//
//  MyPageView.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import SwiftUI
import FirebaseAuth
import MessageUI

struct MyPageView: View {
    @ObservedObject private var loginViewModel = LoginViewModel()
    @State private var showingMailComposer = false
    @State private var isShowingLicenses = false
    @State private var isShowingPrivacyPolicy = false
    @State private var isShowingMailAlert = false
    @State private var isShowingWithdrawAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea(edges: .all)
                
                VStack {
                    if let user = loginViewModel.user {
                        //사용자 정보 표시
                        ScrollView {
                            VStack(spacing: 20) {
                                // 사용자 프로필 섹션
                                profileSection(user: user)
                                
                                // 구분선
                                Divider()
                                    .padding(.horizontal)
                                
                                // 앱 정보 섹션
                                appInfoSection()
                                
                                // 로그아웃 버튼
                                Button(action: {
                                    // Firebase 로그아웃
                                    try? Auth.auth().signOut()
                                    // 애플 리프레시 토큰 제거
                                    UserDefaults.standard.removeObject(forKey: "appleRefreshToken")
                                }) {
                                    Text("로그아웃")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.coralPink)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding()
                                
                                // 회원탈퇴 버튼
                                Button(action: {
                                    isShowingWithdrawAlert = true
                                }) {
                                    Text("회원탈퇴")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.warmGray)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding()

                                .alert(isPresented: $isShowingWithdrawAlert) {
                                    Alert(
                                            title: Text("회원 탈퇴"),
                                            message: Text("정말 탈퇴하시겠습니까? 모든 데이터가 삭제되며 이 작업은 되돌릴 수 없습니다."),
                                            primaryButton: .destructive(Text("탈퇴하기")) {
                                                // 회원 탈퇴 처리
                                                Task {
                                                    do {
                                                        try? Auth.auth().signOut()
                                                        
                                                        // 1. Firestore 데이터 삭제
                                                        try await FireStoreManager.shared.deleteAccount()
                                                       
                                                       // 2. Firebase Auth 계정 삭제
                                                       try await user.delete()
                                                       
                                                       // 3. UserDefaults 데이터 삭제
                                                       UserDefaultsManager.shared.clearUser()
                                                        
                                                        loginViewModel.withDrow()
                                                        
                                                        print("✅ 회원 탈퇴 및 데이터 삭제 완료")
                                                    } catch {
                                                        print("❌ 회원 탈퇴 실패: \(error.localizedDescription)")
                                                    }
                                                }
                                            },
                                            secondaryButton: .cancel(Text("취소"))
                                        )
                                }
                            }
                        }
                    } else {
                        // 사용자 정보가 없는 경우
                        Text("사용자 정보를 불러올 수 없습니다")
                            .foregroundColor(.secondary)
                    }
                }
                .navigationTitle("프로필")
                .sheet(isPresented: $showingMailComposer) {
                    MailComposeView(toRecipients: ["teum282@gmail.com"], subject: "앱 피드백", messageBody: "")
                }
                .sheet(isPresented: $isShowingLicenses) {
                    OpenSourceLicensesView()
                }
                .sheet(isPresented: $isShowingPrivacyPolicy) {
                    PrivacyPolicyView()
                }
            }
        }
    }
    
    // 프로필 섹션
    private func profileSection(user: User) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 15) {
                // 프로필 이미지
                if let photoURL = user.photoURL {
                    AsyncImage(url: photoURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                }
                
                // 사용자 이름 및 이메일
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName ?? UserDefaults.standard.string(forKey: "userName") ?? "사용자")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.midnightBlue)//TODO: black
                    
                    Text(user.email ?? "이메일")
                        .font(.subheadline)
                        .foregroundStyle(Color.deepNavyBlue)
                }
                .padding(.leading, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // 앱 정보 섹션
    private func appInfoSection() -> some View {
        VStack(alignment: .leading) {
            Text("앱 정보")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Button(action: {
                // 버전 정보는 실제로는 앱 번들에서 가져옴
                // 여기서는 간단히 알림으로 표시
            }) {
                SettingRow(iconName: "info.circle.fill", title: "버전 정보", value: getAppVersion())
            }
            
            Button(action: {
                isShowingPrivacyPolicy = true
            }) {
                SettingRow(iconName: "hand.raised.fill", title: "개인정보처리방침")
            }
            
            Button(action: {
                isShowingLicenses = true
            }) {
                SettingRow(iconName: "doc.text.fill", title: "오픈소스 라이센스")
            }
            
            Button(action: {
                if MFMailComposeViewController.canSendMail() {
                    showingMailComposer = true
                } else {
                    isShowingMailAlert = true
                }
            }) {
                SettingRow(iconName: "envelope.fill", title: "피드백 보내기 (메일)")
            }
            // 알림 수정자 추가
            .alert(isPresented: $isShowingMailAlert) {
                Alert(
                    title: Text("메일을 보낼 수 없습니다"),
                    message: Text("이 기기에서 메일 앱이 설정되지 않았습니다. 피드백은 teum282@egmail.com으로 보내주세요."),
                    primaryButton: .default(Text("이메일 주소 복사")) {
                        UIPasteboard.general.string = "teum282@gmail.com"
                    },
                    secondaryButton: .cancel(Text("취소"))
                )
            }
        }
    }
    
    // 앱 버전 가져오기
    private func getAppVersion() -> String {
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return "알 수 없음"
        }
        return "\(appVersion).\(buildNumber)"
    }
    
    // 날짜 포맷터
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// 상세 정보 행 컴포넌트
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.body)
        }
    }
}

// 설정 행 컴포넌트
struct SettingRow: View {
    let iconName: String
    let title: String
    var value: String? = nil
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.mainColor)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

// 메일 작성 뷰
struct MailComposeView: UIViewControllerRepresentable {
    let toRecipients: [String]
    let subject: String
    let messageBody: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.setToRecipients(toRecipients)
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(messageBody, isHTML: false)
        mailComposer.mailComposeDelegate = context.coordinator
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}

// 오픈소스 라이센스 뷰
struct OpenSourceLicensesView: View {
    // 실제로는 앱에서 사용하는 오픈소스 라이브러리 목록을 표시
    let licenses = [
        "Firebase": "Copyright © Google Inc. - Apache License 2.0",
        "SwiftUI": "Copyright © Apple Inc. - Apple Public Source License",
        // 실제 사용하는 라이브러리 추가
    ]
    
    var body: some View {
        List {
            ForEach(licenses.sorted(by: { $0.key < $1.key }), id: \.key) { lib, license in
                VStack(alignment: .leading) {
                    Text(lib)
                        .font(.headline)
                    Text(license)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("오픈소스 라이센스")
    }
}

// 개인정보처리방침 뷰
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("개인정보처리방침")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("본 앱은 사용자의 개인정보를 다음과 같이 처리하고 있습니다.")
                    .padding(.bottom)
                
                Group {
                    Text("1. 수집하는 개인정보의 항목")
                        .font(.headline)
                    Text("- 필수항목: 이메일, 사용자 이름")
                    Text("- 선택항목: 프로필 이미지")
                }
                .padding(.bottom)
                
                Group {
                    Text("2. 개인정보의 수집 및 이용목적")
                        .font(.headline)
                    Text("- 회원 식별 및 서비스 제공")
                    Text("- 서비스 이용 기록 분석 및 통계")
                }
                .padding(.bottom)
                
                // 여기에 더 많은 개인정보처리방침 내용 추가
            }
            .padding()
        }
        .navigationTitle("개인정보처리방침")
    }
}
