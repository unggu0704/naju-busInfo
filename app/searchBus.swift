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

// 🎉 이스터 에그 뷰
struct EasterEggView: View {
    @State private var showImage = false
    @State private var rotation = 0.0
    @State private var scale = 0.5
    @State private var showSparkles = false
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                // 반짝이는 효과
                if showSparkles {
                    ForEach(0..<20, id: \.self) { _ in
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                            .font(.title)
                            .position(
                                x: CGFloat.random(in: 50...350),
                                y: CGFloat.random(in: 100...400)
                            )
                            .opacity(showSparkles ? 1 : 0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: showSparkles)
                    }
                }
                
                VStack(spacing: 20) {
                    // 메시지
                    Text("🎉 홍콩의 추억을 발견! 🎉")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                        .scaleEffect(showImage ? 1.2 : 0.8)
                        .animation(.bouncy(duration: 1.0), value: showImage)
                    
                    // 이미지 (SF Symbol로 대체 - 실제로는 Assets에 이미지 추가)
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 200)
                        
                        // Assets에 추가한 이미지 사용
                        Image("egg") // Assets의 egg 이미지
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                    }
                    .scaleEffect(scale)
                    .rotationEffect(.degrees(rotation))
                    .opacity(showImage ? 1 : 0)
                    .animation(.spring(response: 1.0, dampingFraction: 0.6), value: showImage)
                    .animation(.linear(duration: 3.0).repeatForever(autoreverses: false), value: rotation)
                    
                    // 재미있는 메시지
                    VStack(spacing: 10) {
                        Text("홍콩여행은 끝났지만")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("다음 정류장은 어딜까요? 🚌")
                            .font(.title3)
                            .foregroundColor(.pink)
                    }
                    .opacity(showImage ? 1 : 0)
                    .animation(.easeInOut(duration: 1.0).delay(0.5), value: showImage)
                }
            }
            
            Spacer()
            
            // 재미있는 버튼들
            HStack(spacing: 20) {
                Button(action: {
                    // 하트 애니메이션
                    withAnimation(.spring()) {
                        scale = scale == 1.0 ? 1.2 : 1.0
                    }
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("🏙️")
                    }
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(20)
                }
                
                Button(action: {
                    // 여행하기 - 3바퀴 돌기!
                    withAnimation(.linear(duration: 2.0)) {
                        rotation += 1080 // 3바퀴 (360 * 3)
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("여행하기")
                    }
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(20)
                }
            }
            .opacity(showImage ? 1 : 0)
            .animation(.easeInOut(duration: 1.0).delay(1.0), value: showImage)
            
            Spacer()
        }
        .background(
            LinearGradient(
                colors: [.red.opacity(0.1), .orange.opacity(0.1), .yellow.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            // 순차적 애니메이션
            withAnimation(.easeInOut(duration: 0.8)) {
                showImage = true
            }
            
            withAnimation(.easeInOut(duration: 1.0)) {
                scale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    showSparkles = true
                }
            }
        }
        .navigationTitle("🎉 홍콩의 추억을 발견!")
        .navigationBarTitleDisplayMode(.inline)
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
    
    // 🎉 이스터 에그 체크
    private var isEasterEgg: Bool {
        busstopName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "홍콩"
    }
    
    public var body: some View {
        // 🎉 이스터 에그 조건 확인
        if isEasterEgg {
            EasterEggView()
        } else {
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
            }
            .onAppear {
                searchBusStopNames(by: busstopName)
            }
            
            // 광고 배너 추가
            BannerAdView()
                .frame(width: 320, height: 50)
                .padding(.top)
        }
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
