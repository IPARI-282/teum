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
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            FireStoreTestView()
        }
    }
}
