//
//  KakaoMapCoordinator.swift
//  teum
//
//  Created by 최대성 on 4/28/25.
//

import KakaoMapsSDK

final class KakaoMapCoordinator: NSObject, MapControllerDelegate {
    var controller: KMController?
    var container: KMViewContainer?
    private var first = true
    private var auth = false

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleShowCongestionLabels(notification:)), name: .showCongestionLabels, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleShowCongestionLabels(notification: Notification) {
        guard let areas = notification.object as? [Area] else { return }
        createPois(areas: areas)
    }

    func createController(_ view: KMViewContainer) {
        container = view
        controller = KMController(viewContainer: view)
        controller?.delegate = self
        controller?.prepareEngine()
        addViews()
    }

    func addViews() {
        let defaultPosition = MapPoint(longitude: 126.9780, latitude: 37.5665)
        let info = MapviewInfo(viewName: MapInfo.viewName, viewInfoName: MapInfo.viewInfoName, defaultPosition: defaultPosition)
        _ = controller?.addView(info)
    }
    
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        guard let view = controller?.getView(MapInfo.viewName) as? KakaoMap else { return }
        view.viewRect = container?.bounds ?? .zero

        createLabelLayer()
        createPoiStyles()
        
        view.eventDelegate = self
    }

    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("addViewFailed:", viewName, viewInfoName)
    }

    func containerDidResized(_ size: CGSize) {
        guard let mapView = controller?.getView(MapInfo.viewName) as? KakaoMap else { return }
        mapView.viewRect = CGRect(origin: .zero, size: size)
        
        if first {
            let camera = CameraUpdate.make(target: MapPoint(longitude: 127.108678, latitude: 37.402001), zoomLevel: 10, mapView: mapView)
            mapView.moveCamera(camera)
            first = false
        }
    }

    func authenticationSucceeded() {
        auth = true
        controller?.activateEngine()
    }

    func authenticationFailed(_ errorCode: Int, desc: String) {
        auth = false
        controller?.prepareEngine()
    }

    func createLabelLayer() {
        let view = controller?.getView(MapInfo.viewName) as! KakaoMap
        let manager = view.getLabelManager()
        let layerOption = LabelLayerOptions(
              layerID: MapInfo.Poi.storeLayerID,
              competitionType: .same,   // 겹침 방지
              competitionUnit: .symbolFirst,   // 심볼 우선
              orderType: .rank,
              zOrder: 10001
          )
        _ = manager.addLabelLayer(option: layerOption)
        
        
    }

    func createPoiStyles() {
        guard let view = controller?.getView(MapInfo.viewName) as? KakaoMap else { return }
        let manager = view.getLabelManager()
        
        let styles: [(id: String, color: UIColor)] = [
            (MapInfo.Poi.relaxedStyleID, .systemGreen),
            (MapInfo.Poi.normalStyleID, .systemYellow),
            (MapInfo.Poi.slightCrowdedStyleID, .systemOrange),
            (MapInfo.Poi.crowdedStyleID, .systemRed)
        ]
        
        for (id, fillColor) in styles {
            // 1. 아이콘 (배경 동그라미)
            let size = CGSize(width: 28, height: 28)
            let renderer = UIGraphicsImageRenderer(size: size)
            let iconImage = renderer.image { context in
                let rect = CGRect(origin: .zero, size: size)
                context.cgContext.setFillColor(fillColor.withAlphaComponent(0.7).cgColor)
                context.cgContext.fillEllipse(in: rect)
            }
            let iconStyle = PoiIconStyle(symbol: iconImage, anchorPoint: CGPoint(x: 0.5, y: 0.0))
            
            // 2. 텍스트 스타일
            let textStyle = TextStyle(
                fontSize: 20,
                fontColor: .white,
                strokeThickness: 3,
                strokeColor: .black
            )
            let poiTextStyle = PoiTextStyle(textLineStyles: [
                PoiTextLineStyle(textStyle: textStyle)
            ])
            
            // 3. 통합 스타일
            let poiStyle = PoiStyle(
                styleID: id,
                styles: [
                    PerLevelPoiStyle(iconStyle: iconStyle, textStyle: poiTextStyle, level: 0)
                ]
            )
            
            manager.addPoiStyle(poiStyle)
        }
    }

    func createPois(areas: [Area]) {
        guard let mapView = controller?.getView(MapInfo.viewName) as? KakaoMap else { return }
        let manager = mapView.getLabelManager()
        guard let layer = manager.getLabelLayer(layerID: MapInfo.Poi.storeLayerID) else { return }
        
        layer.clearAllItems()

        var options = [PoiOptions]()
        var points = [MapPoint]()
        
        for area in areas {
            guard let lon = Double(area.y), let lat = Double(area.x) else { continue }
            
            let styleID: String
            switch area.area_congest_num {
            case 1: styleID = MapInfo.Poi.relaxedStyleID
            case 2: styleID = MapInfo.Poi.normalStyleID
            case 3: styleID = MapInfo.Poi.slightCrowdedStyleID
            case 4: styleID = MapInfo.Poi.crowdedStyleID
            default: styleID = MapInfo.Poi.normalStyleID
            }
            
            let mapPoint = MapPoint(longitude: lon, latitude: lat)
            let poiOption = PoiOptions(styleID: styleID, poiID: area.area_nm)
            poiOption.rank = 0
            poiOption.clickable = false
            
            // area_nm을 텍스트로 추가
            let text = PoiText(text: area.area_nm, styleIndex: 0) // 0번 텍스트 스타일 사용
            poiOption.addText(text)
            
            points.append(mapPoint)
            options.append(poiOption)
        }
        
        if options.count == points.count {
            _ = layer.addPois(options: options, at: points) { _ in
                print("✅ POI + 텍스트 추가 완료")
            }
            layer.showAllPois()
        } else {
            print("❗ options와 points 갯수 불일치")
        }
    }
}


extension KakaoMapCoordinator: KakaoMapEventDelegate {
    
    func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String, position: MapPoint) {
        print("poididtapped")
    }
    func kakaoMapDidTapped(kakaoMap: KakaoMap, point: CGPoint) {
        print(point)
    }
    
}
