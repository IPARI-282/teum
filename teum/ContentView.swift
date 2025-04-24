//
//  ContentView.swift
//  teum
//
//  Created by junehee on 4/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel()

    var body: some View {
        if loginViewModel.isLoading {
            // 로딩 화면 표시
            ProgressView("로딩 중...")
                .progressViewStyle(CircularProgressViewStyle())
        } else if loginViewModel.isAuthenticated {
            TabView {
                LookingForTeumView()
                    .tabItem {
                        Image(systemName: "1.square.fill")
                        Text("틈찾기")
                    }
                CommunityView()
                    .tabItem {
                        Image(systemName: "2.square.fill")
                        Text("커뮤니티")
                    }
                FireStoreTestView()
                    .tabItem {
                        Image(systemName: "3.square.fill")
                        Text("틈노트")
                    }
                MyPageView()
                    .tabItem {
                        Image(systemName: "4.square.fill")
                        Text("마이페이지")
                    }
            }
            
        } else {
            LoginView(viewModel: loginViewModel)
        }
        
    }
}

#Preview {
    ContentView()
}
