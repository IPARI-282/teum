//
//  Appdelegate.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import UIKit

import FirebaseCore
import GoogleSignIn
import KakaoMapsSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // 앱 실행 시 초기 설정
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("✅ AppDelegate - didFinishLaunchingWithOptions")
        FirebaseApp.configure()
        
        
        
        print("0909")
        SDKInitializer.InitSDK(appKey: APIKey.kakaoKey)
        print("✅KakaoKey setting success")
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    // 푸시 알림, 백그라운드 처리 등 필요한 delegate 함수 추가 가능
}
