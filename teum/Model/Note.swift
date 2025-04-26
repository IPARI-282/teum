//
//  Note.swift
//  teum
//
//  Created by dream on 4/21/25.
//

import Foundation
import FirebaseFirestore

// 사용자가 작성한 노트(일기, 후기 등) 모델
struct Note: Identifiable, Codable {
    @DocumentID var id: String?                 // Firestore 문서 ID (자동 생성됨)
    var userId: String                          // 작성한 사용자 UID (Auth 기반)
    var title: String                           // 노트 제목
    var date: Date                              // 노트를 작성한 날짜 (사용자 선택)
    var socialBattery: Double                      // 소셜 배터리, 현재는 Int 지만 기획에 따라 Double로 변경 가능
    var district: String                        // 지역 이름 (예: "강남구", "중구")
    var latitude: Double?                       // 장소의 위도
    var longitude: Double?                      // 장소의 경도
    var content: String                         // 노트 내용
    var imagePaths: [String]?                   // 이미지 경로 (Storage URL 또는 path), 최대 5개
    var isPublic: Bool                          // 커뮤니티 공개 여부
    var createdAt: Date                         // 노트 생성 시각
    var updatedAt: Date?                        // 노트 수정 시각 (수정 시점, 없으면 nil), 이건 현재 필요 없다면 주석처리 하고 사용
}

extension Note {
    static var mocking: [Note] {
        (0..<30).map { index in
            Note(
                userId: "test-user",
                title: "Test Note \(index + 1)",
                date: Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date(),
                socialBattery: Double.random(in: 1...100),
                district: ["강남구", "서초구", "마포구", "성동구", "종로구"].randomElement() ?? "강남구",
                content: "이것은 테스트용 노트입니다. 인덱스: \(index + 1)",
                imagePaths: [],
                isPublic: Bool.random(),
                createdAt: Date(),
            )
        }
    }
}
