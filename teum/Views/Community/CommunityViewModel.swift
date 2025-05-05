//
//  CommunityViewModel.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import Foundation
import Combine
import SwiftUICore

final class CommunityViewModel: ObservableObject {
    @Published var trendingNotes: [Note] = []
    @Published var latestNotes: [Note] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var fireStoreManager: FireStoreManager

    init(fireStoreManager: FireStoreManager) {
        self.fireStoreManager = fireStoreManager
    }

    func fetchNotes() async {
        async let trending = fireStoreManager.fetchTrendingNotes()
        async let latest = fireStoreManager.fetchLatestNotes()
        
        do {
            let trendingResult = try await trending
            let latestResult = try await latest
            await MainActor.run {
                self.trendingNotes = trendingResult
                self.latestNotes = latestResult
            }
        } catch {
            print("❌ 에러 발생: \(error)")
        }
    }

    //랜덤 닉네임
    private let nicknames = [
        "말랑곰돌이", "토끼초코", "젤리냥이", "부들햄찌", "솜사탕여우",
        "꼬북꼬북이", "복숭아펭귄", "초코푸딩", "도넛냥", "뽀짝댕댕",
        "무지개젤리", "코알라잠꾸러기", "쪼꼬쪼꼬", "당근비버", "치즈냥",
        "메로나곰", "딸기마카롱", "구름고슴도치", "토실이햄스터", "꾹꾹이발바닥"
    ]

    func nicknameRandom() -> String {
           return nicknames.randomElement() ?? "익명친구"
       }
}
