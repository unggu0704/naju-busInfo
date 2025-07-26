//
//  AppDelegate.swift
//  app
//
//  Created by 김규형 on 11/3/24.
//

import UIKit
import GoogleMobileAds


/**
   Admob용 AppDelegate
 */
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // AdMob 초기화
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
}
