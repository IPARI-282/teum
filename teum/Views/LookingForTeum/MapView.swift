//
//  LookingForTeumView.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import SwiftUI
import KakaoMapsSDK
//import Combine

struct MapView: View {
    @State private var draw: Bool = false
    @StateObject private var geoLoader = GeoJSONLoader()
//    @StateObject private var liveDataLoader = LiveDataJSONLoader()
//    @State private var cancellables = Set<AnyCancellable>()
    @State private var selectedFilter: CongestionFilter = .all

    var body: some View {
        VStack(spacing: 0) {
            CustomHeaderView(title: "틈 찾기")
                .background(.blue)
            ZStack(alignment: .top) {
                KakaoMapView(draw: $draw)
                    .onAppear {
                        geoLoader.fetchAreas()
                        //                    liveDataLoader.fetchLiveDataJSON(for: "가락시장")
                        //                    setupLiveDataSubscriber()
                        draw = true
                    }
                    .onDisappear {
                        draw = false
                    }
                    .onChange(of: selectedFilter) { oldValue, newValue in
                        filterAreas()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                
                FilterButtonsView(selectedFilter: $selectedFilter)
            }
        }
    }
    
//    private func setupLiveDataSubscriber() {
//        liveDataLoader.$welcome
//            .compactMap { $0 }
//            .sink { response in
//                print("실시간 구역:", response.cityData.areaName)
//            }
//            .store(in: &cancellables)
//        
//        liveDataLoader.$errorMessage
//            .compactMap { $0 }
//            .sink { error in
//                print("실시간 데이터 로딩 에러:", error)
//            }
//            .store(in: &cancellables)
//    }
    
    private func filterAreas() {
        let filtered = selectedFilter == .all ? geoLoader.areas : geoLoader.areas.filter { $0.area_congest_num == selectedFilter.congestNum }
        NotificationCenter.default.post(name: .showCongestionLabels, object: filtered)
    }
}

// MARK: - KakaoMapView
struct KakaoMapView: UIViewRepresentable {
    @Binding var draw: Bool

    func makeUIView(context: Context) -> KMViewContainer {
        let view = KMViewContainer(frame: UIScreen.main.bounds)
        context.coordinator.createController(view)
        DispatchQueue.main.async {
            context.coordinator.controller?.prepareEngine()
        }
        return view
    }

    func updateUIView(_ uiView: KMViewContainer, context: Context) {
        if draw {
            DispatchQueue.main.async {
                if context.coordinator.controller?.isEnginePrepared == false {
                    context.coordinator.controller?.prepareEngine()
                }
                if context.coordinator.controller?.isEngineActive == false {
                    context.coordinator.controller?.activateEngine()
                }
            }
        } else {
            context.coordinator.controller?.pauseEngine()
        }
    }

    func makeCoordinator() -> KakaoMapCoordinator {
        KakaoMapCoordinator()
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {
        coordinator.controller?.resetEngine()
    }
}
