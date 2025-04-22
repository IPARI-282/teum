//
//  User.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import Foundation
import FirebaseFirestore

/// Firebase Auth 인증을 통해 가입한 사용자의 기본 정보
struct FirestoreUser: Identifiable, Codable {
    
    @DocumentID var id: String?  // 문서 ID (Firebase UID와 동일). 초기값을 nil로 설정하려고 했지만 Firestore 디코딩 시 id 매핑이 깨질 수 있음
    var name: String // 이름 (Apple/Google 로그인 시 최초 1회 제공)
    var email: String  // 이메일 (Apple/Google 로그인 시 최초 1회 제공)
    var profileImageURL: String?   // 프로필 이미지 URL (Google 로그인 시 제공, Apple은 제공하지 않음), 이 부분은 우리가 제공하는 이미지를 랜덤으로 설정하는 로직으로 변경 예정
}
