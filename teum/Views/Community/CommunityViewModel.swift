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
    @Published var communityList: [Note] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var fireStoreManager: FireStoreManager
    
    init(fireStoreManager: FireStoreManager) {
        self.fireStoreManager = fireStoreManager
    }
    
    func fetchCommunityList() async {
        do {
            let result = try await FireStoreManager.shared.fetchPublicNotes()
            self.communityList = result
        } catch {
            print("❌ 에러 발생: \(error)")
        }
    }
}
