//
//  AppDelegate.swift
//  app
//
//  Created by 김규형 on 11/3/24.
//

import UIKit
import GoogleMobileAds

/**
   AdMob용 AppDelegate
 */
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print("🚀 AdMob 초기화 시작...")
        
        // AdMob 초기화
        GADMobileAds.sharedInstance().start { status in
            print("✅ AdMob 초기화 완료!")
            
            // 어댑터 상태 로깅
            for adapter in status.adapterStatusesByClassName {
                let adapterStatus = adapter.value
                print("📱 어댑터: \(adapter.key) - 상태: \(adapterStatus.state.rawValue)")
                
                if adapterStatus.state == .notReady {
                    print("⚠️ 어댑터 \(adapter.key)가 준비되지 않음: \(adapterStatus.description)")
                }
            }
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("📱 앱이 활성화됨 - AdMob 상태 확인")
    }
}
