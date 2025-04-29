//
//  NameSpace.swift
//  teum
//
//  Created by 최대성 on 4/29/25.
//

import Foundation

enum MapInfo {
    static let viewName = "congestion"
    static let viewInfoName = "map"
    
    enum Poi {
        static let storeLayerID = "storeLayer"
        static let basicPoiPinStyleID = "basicPoiPinStyle"
        static let tappedPoiPinStyleID = "tappedPoiPinStyle"
        
        static let relaxedStyleID = "RelaxedStyle"
        static let normalStyleID = "NormalStyle"
        static let slightCrowdedStyleID = "SlightCrowdedStyle"
        static let crowdedStyleID = "CrowdedStyle"
    }
}
