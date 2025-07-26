import Foundation
import CoreData
import UIKit
import SwiftUI

struct ApiResponse: Codable {
    let arriveList: [Arrival]
    let rowCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case arriveList = "ARRIVE_LIST"
        case rowCount = "ROW_COUNT"
    }
}

struct Arrival: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let lineName: String
    let remainStop: Int
    let remainMin: Int
    let busStopName: String
    let lineID: Int
    
    private enum CodingKeys: String, CodingKey {
        case lineName = "LINE_NAME"
        case remainStop = "REMAIN_STOP"
        case remainMin = "REMAIN_MIN"
        case busStopName = "BUSSTOP_NAME"
        case lineID = "LINE_ID"
    }
}

public struct SearchResultView: View {
    @Binding var busstopName: String    // 버스 이름 변수
    @State private var isLoading = true 
    @State private var busStopNames: [String] = []  // 정류장 이름 배열 추가
    @State private var nextBusStops: [String] = []  // 정류장 이름 배열 추가
    @State private var busStopIDs: [Int] = []  // 정류장 이름 배열 추가
    @State private var isBool:Bool = false
    @State private var isPresented = false
    public var body: some View {
        ZStack {
            VStack {
                if busStopNames.isEmpty {
                    Spacer()
                    Text("검색된 정류장이 없습니다.")
                }
                List(busStopNames.indices, id: \.self) { index in
                    //다음 정류장 방향 같은 경우 미리 " 방향"을 붙여서 전달한다! 240318 수정
                    NavigationLink(destination: busInfoResult(busStopName: busStopNames[index], busStopID: busStopIDs[index], nextBusStop: nextBusStops[index].isEmpty ? "다음 정류장 없음" : nextBusStops[index] + " 방향")){
                        VStack(alignment: .leading, spacing: 4) {
                            Text("정류장 이름: \(busStopNames[index])")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            
                            if nextBusStops[index].isEmpty {
                                Text("다음 정류장 없음")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            } else {
                                Text("\(nextBusStops[index]) 방향")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            
                            Divider()
                        }
                    }
                }.navigationTitle("검색결과")
            }
            if isLoading {
                LoadingView()
            }
        } .onAppear {
            searchBusStopNames(by: busstopName)
        }
        
        // 광고 배너 추가
          BannerAdView()
              .frame(width: 320, height: 50)
              .padding(.top)
        
    }
    
    public func searchBusStopNames(by busName: String) {
        print("Searching bus stop names")
        
        let persistenceController = PersistenceController.shared
        let context = persistenceController.container.viewContext
        
        // Retrieve all bus stops with the given name from CoreData
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "busStopName CONTAINS[c] %@", busName)
        
        do {
            let fetchedItems = try context.fetch(fetchRequest)
            guard !fetchedItems.isEmpty else {
                busStopNames = []
                isLoading = false
                return
            }
            
            busStopNames = fetchedItems.compactMap { $0.busStopName }
            nextBusStops = fetchedItems.compactMap { $0.nextBusStop }
            busStopIDs = fetchedItems.compactMap {Int($0.busStopID) }
            isLoading = false
        } catch {
            print("Error fetching bus stop data: \(error)")
            busStopNames = []
            nextBusStops = []
            isLoading = false
        }
    }
    
}



