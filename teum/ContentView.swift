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
        NavigationStack(path: $coordinator.paths) { // NavigationStack 제일 위
            VStack {
                if loginViewModel.isLoading {
                    ProgressView("로딩 중...")
                } else if loginViewModel.isAuthenticated {
                    TabView { // TabView는 NavigationStack 내부
                        MapView()
                            .tabItem { Label("틈찾기", systemImage: "map") }
                        CommunityView()
                            .tabItem { Label("커뮤니티", systemImage: "bubble.left.and.bubble.right.fill") }
                        TeumNoteView()
                            .tabItem { Label("틈노트", systemImage: "square.and.pencil") }
                        MyPageView()
                            .tabItem { Label("마이페이지", systemImage: "person.crop.circle") }
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
                    TeumNoteView()
                case .lookingForTeum:
                    MapView()
                case .login:
                    LoginView(viewModel: loginViewModel)
                case .TeumNoteWrite:
                    TeumNoteWriteView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
