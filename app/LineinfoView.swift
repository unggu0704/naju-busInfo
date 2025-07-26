//
//  LineinfoView.swift
//  app
//
//  Created by 김규형 on 2023/07/19.
//

import Foundation
import CoreData
import UIKit
import SwiftUI

struct LineApiResponse: Codable {
    let LineList: [Line]
    let rowCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case LineList = "BUSSTOP_LIST"
        case rowCount = "ROW_COUNT"
    }
}

struct LocationApiResponse: Codable {
    let LocationList: [Location]
    let rowCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case LocationList = "BUSLOCATION_LIST"
        case rowCount = "ROW_COUNT"
    }
}

struct Line: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let busStopID: Int
    let busStopName: String
    
    private enum CodingKeys: String, CodingKey {
        case busStopName = "BUSSTOP_NAME"
        case busStopID = "BUSSTOP_ID"
    }
}

struct Location: Codable {
    let id = UUID()
    let busStopID: Int
    let busNo: String
    
    private enum CodingKeys: String, CodingKey {
        case busNo = "BUS_NO"
        case busStopID = "BUSSTOP_ID"
    }
}

struct LineinfoView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    public var LineID: Int // 버스 ID 받아옴
    public var Linename: String
    public var nowbusStopID: Int?
    @State private var selectedLine: [Line] = []
    @State private var selectedLocation: [Location] = []
    @State private var isRotating = false
    @State private var showPDFViewer = false
    
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showAlert = false
    @State private var alertMessage = "" // 에러 메시지를 저장할 변수
    @State private var scrollToIndex: Int = 0
    @State private var isLoading = true
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                VStack {
                    if selectedLine.isEmpty {
                        Text("노선 정보가 없습니다. (나주버스만 제공됩니다.)")
                    } else {
                        ScrollView {
                            VStack {
                                ForEach(selectedLine.indices, id: \.self) { index in
                                    
                                    HStack(alignment: .center, spacing: 8) {
                                        if let location = findBusLocation(for: selectedLine[index].busStopID) {
                                            if Linename.contains("셔틀") || Linename.contains("우정") || Linename.contains("그린") {
                                                Image(systemName: "bus")
                                                    .font(.title)
                                                    .foregroundColor(.green)
                                                    .frame(width: 30) // 버스 그림의 너비를 지정해줍니다.
                                            } else if Linename.contains("99") ||
                                                        Linename.contains("161") || Linename.contains("160") {
                                                Image(systemName: "bus")
                                                    .font(.title)
                                                    .foregroundColor(.purple)
                                                    .frame(width: 30) // 버스 그림의 너비를 지정해줍니다.
                                            }  else if Linename.contains("급행") || Linename.contains("좌석")  {
                                                Image(systemName: "bus")
                                                    .font(.title)
                                                    .foregroundColor(.red)
                                                    .frame(width: 30)
                                            } else {
                                                Image(systemName: "bus")
                                                    .font(.title)
                                                    .foregroundColor(.blue)
                                                    .frame(width: 30) // 버스 그림의 너비를 지정해줍니다.
                                            }
                                            
                                        } else if (nowbusStopID == selectedLine[index].busStopID) {
                                            Circle()
                                                .offset(x: -2)
                                                .frame(width: 30, height: 15)
                                                .foregroundColor(.red)
                                        } else {
                                            Circle()
                                                .frame(width: 25, height: 10)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        if (nowbusStopID == selectedLine[index].busStopID) {
                                            Text("\(selectedLine[index].busStopName)")
                                                .font(.headline)
                                                .id(-1) // 최초 스크롤 위치를 이동시키기 위한 ID
                                                .padding()
                                        } else {
                                            Text("\(selectedLine[index].busStopName)")
                                                .font(.headline)
                                                .padding()
                                        }
                                        
                                        if let location = findBusLocation(for: selectedLine[index].busStopID) {
                                            Text("\(location.busNo)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer() // 버스 정류장 점과 버스 정류장 이름을 수평으로 맞추기 위해 Spacer 추가
                                        if (nowbusStopID == selectedLine[index].busStopID) {
                                            Text("내 위치 ")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }.padding(.vertical, -10)
                                    Divider()
                                    
                                } // foreach 대괄호
                                .foregroundColor(.gray)
                            }.navigationBarTitle("\(Linename) 번 버스 전체 정보 ")
                                .onAppear {
                                    proxy.scrollTo(-1, anchor: .center)
                                }
                        }.toolbar {
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                Spacer()
                                
                                Menu {
                                    Button(action: {
                                        saveToWishList()
                                    }) {
                                        Label("즐겨찾기", systemImage: "heart.fill")
                                    }
                                    .alert(isPresented: $showAlert) {
                                        Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                                    }
                                    
                                    Button(action: {
                                        showPDFViewer = true
                                    }) {
                                        Label("시간표 보기", systemImage: "calendar")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                }
                                
                                Button(action: {
                                    if networkMonitor.isConnected {
                                        isRotating.toggle()
                                        fetchLineData(for: LineID)
                                        fetchLocationData(for: LineID)
                                        print("버튼 실행")
                                    } else {
                                        alertMessage = "네트워크 연결이 필요합니다. 연결을 확인해주세요."
                                        showAlert = true
                                    }
                                }) {
                                    Image(systemName: "arrow.clockwise.circle")
                                        .rotationEffect(.degrees(isRotating ? 360 : 0))
                                        .animation(.easeInOut(duration: 0.5), value: isRotating)
                                }
                            }
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                        }
                        .padding(.horizontal, 16)
                        .listStyle(PlainListStyle())
                        .overlay(
                            // Draw the connecting line with a Path
                            Path { path in
                                if selectedLine.indices.contains(0), selectedLine.indices.contains(selectedLine.count - 1) {
                                    let firstPoint = CGPoint(x: 29, y: 0) // 첫 번째 정류장 위치
                                    let lastPoint = CGPoint(x: 29, y: UIScreen.main.bounds.height + 50) // 화면 아래쪽으로 경로를 연결
                                    path.move(to: firstPoint)
                                    path.addLine(to: lastPoint)
                                }
                            }
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .cornerRadius(10) // 모서리를 둥글게 만듭니다.
                    } // else 종료
                    
                }
                
                if isLoading {
                    LoadingView()
                }
            }
            .navigationBarTitle("\(Linename)번 버스 위치 정보 ")
            .onAppear {
                if networkMonitor.isConnected {
                    fetchLineData(for: LineID)
                    fetchLocationData(for: LineID)
                } else {
                    alertMessage = "네트워크 연결이 필요합니다. 연결을 확인해주세요."
                    showAlert = true
                }
            }
            .sheet(isPresented: $showPDFViewer) {
                // 모달로 표시될 PDFViewer
                // PDFViewer를 전달하여 모달로 표시
                PDFViewer(selectedPDFNumber: Linename)
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.bottom, -30)
    } // 바디
    
    public func fetchLineData(for LineID: Int) { // 전체 노선 정보를 불러오는 데이터
        guard networkMonitor.isConnected else {
            alertMessage = "네트워크 연결이 필요합니다. 연결을 확인해주세요."
            showAlert = true
            isLoading = false
            return
        }
        
        // Construct the URL for the API request
        guard var urlComponents = URLComponents(string: "http://121.147.206.212/json/lineStationInfo") else {
            print("Invalid URL")
            isLoading = false
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "LINE_ID", value: "\(LineID)")
        ]
        print("API 요청 사이트: " + "\(urlComponents)")
        guard let url = urlComponents.url else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
            
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                alertMessage = "\(error.localizedDescription)"
                showAlert = true
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    alertMessage = "데이터를 받을 수 없습니다."
                    showAlert = true
                }
                return
            }
            
            do {
                let LineApiResponse = try JSONDecoder().decode(LineApiResponse.self, from: data)
                let decodedLine = LineApiResponse.LineList
                
                DispatchQueue.main.async {
                    if decodedLine.isEmpty {
                        print("No bus arrivals found for bus stop ID: \(LineID)")
                    } else {
                        self.selectedLine = decodedLine // 첫 번째 도착 정보를 선택
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "JSON 데이터를 디코딩하는 중 오류 발생: \(error)"
                    showAlert = true
                }
            }
        }.resume()
    }
    
    public func fetchLocationData(for LineID: Int) { // 노선의 현재 있는 위치만 불러오는 데이터
        
        // Construct the URL for the API request
        guard var urlComponents = URLComponents(string: "http://121.147.206.212/json/busLocationInfo") else {
            print("Invalid URL")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "LINE_ID", value: "\(LineID)")
        ]
        print("API 요청 사이트: " + "\(urlComponents)")
        guard let url = urlComponents.url else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                alertMessage = "\(error.localizedDescription)"
                showAlert = true
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    alertMessage = "데이터를 받을 수 없습니다."
                    showAlert = true
                }
                return
            }
            
            do {
                let LocationApiResponse = try JSONDecoder().decode(LocationApiResponse.self, from: data)
                let decodedLine1 = LocationApiResponse.LocationList
                
                DispatchQueue.main.async {
                    if decodedLine1.isEmpty {
                        print("No bus arrivals found for bus stop ID: \(LineID)")
                    } else {
                        self.selectedLocation = decodedLine1 // 첫 번째 도착 정보를 선택
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "JSON 데이터를 디코딩하는 중 오류 발생: \(error)"
                    showAlert = true
                }
            }
        }.resume()
    }
    
    func saveToWishList() {
        let fetchRequest: NSFetchRequest<WishListOfLine> = WishListOfLine.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "lineID == %d", LineID)
        
        do {
            let existingWishList = try viewContext.fetch(fetchRequest)
            
            if let wishItem = existingWishList.first {
                // 이미 해당 ID를 가진 항목이 있으면 삭제 여부를 확인
                let confirmDeleteAlert = UIAlertController(title: "알림", message: "이 노선을 즐겨찾기에서 삭제하시겠습니까?", preferredStyle: .alert)
                confirmDeleteAlert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                    viewContext.delete(wishItem)
                    showAlert = true
                    alertMessage = "즐겨찾기에서 삭제되었습니다."
                    
                    do {
                        try viewContext.save()
                    } catch {
                        print("Failed to save changes after deletion: \(error)")
                    }
                }))
                confirmDeleteAlert.addAction(UIAlertAction(title: "취소", style: .cancel))
                
                // 현재 화면의 UIViewController를 가져와서 확인 메시지를 표시
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let viewController = window.rootViewController {
                    viewController.present(confirmDeleteAlert, animated: true)
                }

            } else {
                // 해당 ID를 가진 항목이 없으면 추가
                let newWishList = WishListOfLine(context: viewContext)
                newWishList.lineID = Int32(LineID)
                newWishList.lineName = Linename
                showAlert = true
                alertMessage = "즐겨찾기에 추가되었습니다."
                
                try viewContext.save() // 변경 내용을 저장합니다
            }
            
        } catch {
            print("Failed to fetch existing wishlist item: \(error)")
        }
    }

    
    private func findBusLocation(for busStopID: Int) -> Location? {
        return selectedLocation.first(where: { $0.busStopID == busStopID })
    }
}
