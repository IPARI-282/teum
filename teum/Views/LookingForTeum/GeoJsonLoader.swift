// GeoJSONLoader.swift
// KaKaoMap
// Created by 최대성 on 4/14/25.

import Foundation
//import Combine

class GeoJSONLoader: ObservableObject {
//    @Published var seoulGeoJSON: SeoulGeoJSON?
//    @Published var guJson: FeatureCollection?
    @Published var areas: [Area] = []
    @Published var errorMessage: String?
    
//    private var cancellables = Set<AnyCancellable>()
    
//    init() {
//        loadGuJson()
//    }
//    
//    func loadGeoJSON() {
//        guard let url = Bundle.main.url(forResource: "SeoulCity", withExtension: "geojson") else {
//            print("seoul.geojson 파일을 찾을 수 없습니다")
//            return
//        }
//        do {
//            let data = try Data(contentsOf: url)
//            let decoder = JSONDecoder()
//            let geoJSON = try decoder.decode(SeoulGeoJSON.self, from: data)
//            DispatchQueue.main.async {
//                self.seoulGeoJSON = geoJSON
//                NotificationCenter.default.post(name: .drawSeoulBoundary, object: geoJSON)
//            }
//        } catch {
//            print("JSON 디코딩 에러: \(error)")
//        }
//    }
//    
//    func loadGuJson() {
//        guard let url = Bundle.main.url(forResource: "GuSeoulCity", withExtension: "geojson") else {
//            print("GuSeoulCity.geojson 파일을 찾을 수 없습니다")
//            return
//        }
//        do {
//            let data = try Data(contentsOf: url)
//            let decoder = JSONDecoder()
//            let geoJSON = try decoder.decode(FeatureCollection.self, from: data)
//            DispatchQueue.main.async {
//                self.guJson = geoJSON
//                NotificationCenter.default.post(name: .drawSeoulBoundary, object: geoJSON)
//            }
//        } catch {
//            print("JSON 디코딩 에러: \(error)")
//        }
//    }
    
    func fetchAreas() {
        guard let url = URL(string: "https://data.seoul.go.kr/SeoulRtd/getCategoryList?page=1&category=전체보기&count=116") else {
            print("Invalid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching JSON: \(error)")
                return
            }
            guard let data = data else {
                print("No data returned")
                return
            }
            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self.areas = apiResponse.row
                    NotificationCenter.default.post(name: .showCongestionLabels, object: apiResponse.row)
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        .resume()
    }
}
