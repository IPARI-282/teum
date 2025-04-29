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
}
