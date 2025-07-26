//
//  SearchLineResultView.swift
//  app
//
//  Created by 김규형 on 6/17/24.
//

import SwiftUI
import CoreData

struct SearchLineResultView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var busRouteNumber: String
    @State private var matchedItems: [LineInfo] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            VStack {
                if matchedItems.isEmpty {
                    Text("해당 노선의 버스를 찾을 수 없습니다.")
                        .padding()
                } else {
                    List(matchedItems, id: \.self) { item in
                        let lineID = Int(item.lineID) //Int32 -> Int로 unwrapping
                        if let lineName = item.lineName{
                            NavigationLink(destination: LineinfoView(LineID: lineID, Linename: lineName, nowbusStopID: 99999)) {
                                HStack {
                                    if lineName.contains("99") || lineName.contains("161")
                                        || lineName.contains("160"){
                                        VStack(alignment: .center, spacing: 5) {
                                            Image(systemName: "bus")
                                                .font(.title)
                                                .foregroundColor(.purple)
                                            Text(" \(lineName)")
                                                .font(.headline)
                                        }
                                    } else if lineName.contains("셔틀") || lineName.contains("우정") || lineName.contains("그린") {
                                        VStack(alignment: .center, spacing: 5) {
                                            Image(systemName: "bus")
                                                .font(.title)
                                                .foregroundColor(.green)
                                            Text(" \(lineName)")
                                                .font(.headline)
                                        }
                                    }else if lineName.contains("급행") || lineName.contains("좌석")  {
                                        VStack(alignment: .center, spacing: 5) {
                                            Image(systemName: "bus")
                                                .font(.title)
                                                .foregroundColor(.red)
                                            Text(" \(lineName)")
                                                .font(.headline)
                                        }
                                    }
                                    else {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Image(systemName: "bus")
                                                .font(.title)
                                                .foregroundColor(.blue)
                                            Text(" \(lineName)")
                                                .font(.headline)
                                        }
                                    }
                                    // 상세 정보 표기
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("\(item.dirUpName ?? "정보 없음") ~ \(item.dirDownName ?? "정보 없음")")
                                            .font(.subheadline)
                                        Text("첫차 시간: \(item.firstTime ?? "정보 없음")")
                                            .font(.subheadline)
                                        Text("막차 시간: \(item.lastTime ?? "정보 없음")")
                                            .font(.subheadline)
                                        Text("경유지: \(item.dirPass ?? "정보 없음")")
                                            .font(.subheadline)
                                            .lineLimit(2) // 경유지 텍스트의 줄 수 제한
                                    }
                                    
                                }
                                .padding(.vertical, 5)
                            }
                        } else {
                            Text("Unknown")
                        }
                    }
                }
                // 광고 배너 추가
                  BannerAdView()
                      .frame(width: 320, height: 50)
                      .padding(.top)
            }
            
            if isLoading {
                LoadingView()
            }
        }
        .onAppear {
            fetchMatchingItems()
        }
        .navigationTitle("노선 검색 결과")
    }

    private func fetchMatchingItems() {
        let fetchRequest: NSFetchRequest<LineInfo> = LineInfo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "lineName CONTAINS[c] %@", busRouteNumber)

        do {
            matchedItems = try viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch items: \(error)")
        }
        
        isLoading = false
    }
}
