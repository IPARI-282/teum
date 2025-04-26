//
//  teumApp.swift
//  teum
//
//  Created by junehee on 4/6/25.
//

import SwiftUI

import FirebaseCore
import FirebaseFirestore

@main
struct teumApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var coordinator = AppCoordinator<Destination>()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
        }
    }
}
