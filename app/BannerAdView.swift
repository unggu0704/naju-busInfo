//
//  BannerAdView.swift
//  app
//
//  Created by 김규형 on 11/3/24.
//
import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    class Coordinator: NSObject, GADBannerViewDelegate {
        func bannerViewDidLoadAd(_ banner: GADBannerView) {
            print("Banner ad loaded successfully.")
        }

        //광고 로그 확인
        func bannerView(_ banner: GADBannerView, didFailToReceiveAdWithError error: Error) {
            if let error = error as NSError? {
                print("Failed to load banner ad: \(error.localizedDescription)")
            } else {
                print("Failed to load banner ad: Unknown error")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        let testUnitId = "ca-app-pub-3940256099942544/2934735716"

        // 환경 변수에서 광고 단위 ID를 가져옵니다.
        let adUnitID = ProcessInfo.processInfo.environment["AD_UNIT_ID"] ?? "ERROR" // 기본 테스트 ID
        print("Ad Unit ID: \(adUnitID)") // 로그로 출력

        bannerView.adUnitID = adUnitID // 환경 변수 사용
        bannerView.rootViewController = UIApplication.shared.windows.first?.rootViewController
        bannerView.delegate = context.coordinator // Delegate 설정
        bannerView.load(GADRequest())
        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
