//
//  UserDefaultsManager.swift
//  teum
//
//  Created by dream on 4/21/25.
//

import SwiftUI

enum UserDefaultsKeys {
    static let userId = "userId"
    static let name = "name"
    static let email = "email"
    static let profileImageURL = "profileImage"
}

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    @AppStorage(UserDefaultsKeys.userId) var userId: String = ""
    @AppStorage(UserDefaultsKeys.name) var name: String = ""
    @AppStorage(UserDefaultsKeys.email) var email: String = ""
    @AppStorage(UserDefaultsKeys.profileImageURL) var profileImageURL: String = ""

    private init() { }

    // Firestore에서 받아온 유저 정보 저장
    func updateUser(_ user: FirestoreUser) {
        userId = user.id ?? ""
        name = user.name
        email = user.email
        profileImageURL = user.profileImageURL ?? ""
    }

    // 로그아웃 또는 회원탈퇴 시 유저 정보 삭제
    func clearUser() {
        userId = ""
        name = ""
        email = ""
        profileImageURL = ""
    }
}
