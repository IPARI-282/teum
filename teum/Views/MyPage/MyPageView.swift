//
//  MyPageView.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import SwiftUI

import FirebaseAuth

struct MyPageView: View {
    @ObservedObject private var loginViewModel = LoginViewModel()

    var body: some View {
        NavigationView {

            ZStack {
                Color.white.ignoresSafeArea(edges: .all)
                
                VStack {
                    if let user = loginViewModel.user {
                        //사용자 정보 표시
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                //프로필 헤어
                                HStack(spacing: 15) {
                                    //프로필 이미지
                                    if let photoURL = user.photoURL {
                                        AsyncImage(url: photoURL) {
                                            image in
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
                                    
                                    //사용자 이름 및 이메일
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text((user.displayName ?? UserDefaults.standard.string(forKey: "userName"))!)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.black)
                                        
                                        Text(user.email ?? "이메일")
                                            .font(.subheadline)
                                            .foregroundStyle(.blue)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // 사용자 세부 정보
                                    VStack(alignment: .leading, spacing: 15) {
                                        DetailRow(title: "사용자 ID", value: user.uid)
                                        
                                        if let creationDate = user.metadata.creationDate {
                                            DetailRow(title: "계정 생성일", value: dateFormatter.string(from: creationDate))
                                        }
                                        
                                        if let lastSignInDate = user.metadata.lastSignInDate {
                                            DetailRow(title: "최근 로그인", value: dateFormatter.string(from: lastSignInDate))
                                        }
                                        
                                        DetailRow(title: "이메일 인증 여부", value: user.isEmailVerified ? "인증됨" : "인증되지 않음")
                                        
                                        DetailRow(title: "로그인 방법", value: user.providerData.first?.providerID ?? "알 수 없음")
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                            }
                            // 로그아웃 버튼
                            Button(action: {
                                try? Auth.auth().signOut()
                            }) {
                                Text("로그아웃")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.red.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding()
                        }
                    } else {
                        // 사용자 정보가 없는 경우 (이 부분은 사실상 표시되지 않아야 함)
                        Text("사용자 정보를 불러올 수 없습니다")
                            .foregroundColor(.secondary)
                    }
                }
                .navigationTitle("프로필")
            }
        }
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
