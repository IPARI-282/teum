//
//  GeoCongestion.swift
//  teum
//
//  Created by 최대성 on 4/29/25.
//

import Foundation
import SwiftUI

struct APIResponse: Decodable {
    let pageRange: [Int]
    let total: Int
    let row: [Area]
}

struct Area: Decodable {
    let area_nm: String
    let congestion_color: String
    let x: String // 위도
    let y: String // 경도
    let area_congest_lvl: String
    let category: String
    let area_congest_num: Int
}

enum CongestionFilter: CaseIterable {
    case all, free, normal, high, severe
    
    var title: String {
        switch self {
        case .all: return "전체"
        case .free: return "여유"
        case .normal: return "보통"
        case .high: return "혼잡"
        case .severe: return "매우혼잡"
        }
    }
    
    var congestNum: Int {
        switch self {
        case .free: return 1
        case .normal: return 2
        case .high: return 3
        case .severe: return 4
        case .all: return 0
        }
    }
    
    var color: Color {
        switch self {
        case .free: return .green
        case .normal: return .yellow
        case .high: return .orange
        case .severe: return .red
        case .all: return .gray
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "globe"
        case .free: return "figure.walk"
        case .normal: return "car"
        case .high: return "car.fill"
        case .severe: return "exclamationmark.triangle.fill"
        }
    }
}
