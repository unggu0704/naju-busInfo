//
//  LoadingView.swift
//  app
//
//  Created by 김규형 on 10/9/24.
//
import SwiftUI

/*
    로딩 뷰
 */
struct LoadingView: View {
    var body: some View {
        VStack {
            Text("정보 불러오는중 ...")
                .font(.headline)
                .foregroundStyle(.black)
            ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .foregroundColor(.white)
    }
}
