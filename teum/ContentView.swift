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
        if loginViewModel.isAuthenticated {
            LookingForTeumView()
        } else {
            LoginView(viewModel: loginViewModel)
        }
        
    }
}

#Preview {
    ContentView()
}
