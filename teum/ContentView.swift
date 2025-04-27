//
//  ContentView.swift
//  teum
//
//  Created by junehee on 4/6/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @EnvironmentObject var coordinator: AppCoordinator<Destination>
    
    var body: some View {
        NavigationStack(path: $coordinator.paths) {
            if loginViewModel.isLoading {
                ProgressView("로딩 중...")
            } else if loginViewModel.isAuthenticated {
                TabView {
                    LookingForTeumView()
                        .tabItem { Label("틈찾기", systemImage: "1.square.fill") }
                    CommunityView()
                        .tabItem { Label("커뮤니티", systemImage: "2.square.fill") }
                    FireStoreTestView()
                        .tabItem { Label("틈노트", systemImage: "3.square.fill") }
                    MyPageView()
                        .tabItem { Label("마이페이지", systemImage: "4.square.fill") }
                }
            } else {
                LoginView(viewModel: loginViewModel)
            }
        }
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case .community:
                CommunityView()
            case .myPage:
                MyPageView()
            case .teumNote:
                FireStoreTestView()
            case .lookingForTeum:
                LookingForTeumView()
            case .login:
                LoginView(viewModel: loginViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
