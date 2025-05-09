//
//  LoginView.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import SwiftUI

import AuthenticationServices

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        ZStack {
            Image("teumBackground2")
                .resizable()
                .ignoresSafeArea()
            
            VStack() {
                Spacer(minLength: 60)
                
                Text("틈")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 8)

                Text("혼자 놀기 좋은 공간을 찾아드릴게요")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    //.padding(40)
                
                Spacer()
                
                //애플 로그인 버튼
                SignInWithAppleButton(.continue, onRequest: { request in
                    viewModel.send(action: .appleLogin(request))
                }, onCompletion: { result in
                    viewModel.send(action: .appleLoginHandler(result))
                })
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                
                Button {
                    viewModel.loginWithGoogle()
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .foregroundStyle(Color.gray)
                            .font(.title2 )
                        Text("Continue with Google")
                            .foregroundStyle(Color.gray)
                            .font(.title2 )
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 30)
        }
    }
}

