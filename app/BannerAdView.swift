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

        func bannerView(_ banner: GADBannerView, didFailToReceiveAdWithError error: Error) {
            if let error = error as NSError? {
                print("Failed to load banner ad: \(error.localizedDescription)")
            } else {
                print("Failed to load banner ad: Unknown error")
            }
        }
        
        func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
            print("Banner ad recorded an impression.")
        }
        
        func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
            print("Banner ad will present screen.")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        
        // 실제 광고 단위 ID 사용
        bannerView.adUnitID = "ca-app-pub-9390512785486955/9425124606"
        
        // 루트 뷰 컨트롤러 설정
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            bannerView.rootViewController = window.rootViewController
        }
        
        bannerView.delegate = context.coordinator
        bannerView.load(GADRequest())
        
        return bannerView
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
