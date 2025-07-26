
import SwiftUI
import CoreData

struct busInfoResult: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: WishList.entity(), sortDescriptors: []) var wishList: FetchedResults<WishList>
    @State private var selectedArrival: [Arrival] = []
    var busStopName: String
    var busStopID:Int
    var nextBusStop: String
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isRotating = false
    @State private var isLoading = false
    
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Section(header: HStack {
                    Text(busStopName)
                        .font(.custom("NotoSans-Bold", size: 24))
                        .lineLimit(1) // 한 줄로 제한
                        .minimumScaleFactor(0.5) // 최소 축소 비율 설정
                        .padding(.leading, 20) // 왼쪽 여백 추가
                    Spacer()
                    Text(nextBusStop)
                        .font(.subheadline)
                        .lineLimit(1) // 한 줄로 제한
                        .minimumScaleFactor(0.5) // 최소 축소 비율 설정
                        .padding(.trailing, 38) // 오른쪽 여백 추가
                        .padding(.bottom, -10)
                }.padding(.bottom, -5)
                ) {
                    
                    //정류장 정보가 아무것도 없을때 표시
                    if selectedArrival.isEmpty {
                        ZStack {
                            VStack {
                                Spacer()
                                Text("현재 정류장 버스 정보가 없습니다.")
                                    .multilineTextAlignment(.center)
                                    .padding() // 원하는 여백을 추가합니다.
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    List(selectedArrival.indices, id: \.self) { index in
                        let lineInfo = selectedArrival[index]
                        
                        
                        HStack(spacing: 16) {
                            if lineInfo.lineName.contains("셔틀")||lineInfo.lineName.contains("우정") || lineInfo.lineName.contains("그린") {
                                Image(systemName: "bus")
                                    .font(.title)
                                    .foregroundColor(.green)
                            } else if lineInfo.lineName.contains("99") ||
                                        lineInfo.lineName.contains("160") || lineInfo.lineName.contains("161"){
                                Image(systemName: "bus")
                                    .font(.title)
                                    .foregroundColor(.purple)
                            } else if lineInfo.lineName.contains("급행") || lineInfo.lineName.contains("좌석")  {
                                Image(systemName: "bus")
                                    .font(.title)
                                    .foregroundColor(.red)
                                    .frame(width: 30)
                            } else {
                                Image(systemName: "bus")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
                            
                            
                            NavigationLink(destination: LineinfoView(LineID: lineInfo.lineID, Linename: lineInfo.lineName, nowbusStopID: busStopID)){
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(lineInfo.lineName)번")
                                        .font(.headline)
                                    
                                    Text("남은 시간: \(lineInfo.remainMin) 분")
                                        .font(.subheadline)
                                    
                                    Text("도착까지 남은 정류장 갯수: \(lineInfo.remainStop)")
                                        .font(.subheadline)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        
                        .cornerRadius(10)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                saveToWishList()
                            }) {
                                Image(systemName: "heart.fill")
                            }.alert(isPresented: $showAlert) {
                                Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                isRotating.toggle()
                                fetchData(for: busStopID)
                            }) {
                                Image(systemName: "arrow.clockwise.circle")
                                    .rotationEffect(.degrees(isRotating ? 360 : 0))
                                    .animation(.easeInOut(duration: 0.5), value: isRotating)
                            }
                        }
                        
                    }
                }
                // 광고 배너 추가 (VStack 하단에 배치)
                    HStack {
                        Spacer() // 좌측 여백을 위해 Spacer 추가
                        BannerAdView()
                            .frame(width: 320, height: 50)
                            .padding(.top)
                        Spacer() // 우측 여백을 위해 Spacer 추가
                    }
            }

            if isLoading {
                LoadingView()
            }
        }
        .onAppear(){
            fetchData(for: busStopID)
        }

    }
    
    
    func saveToWishList() {
        withAnimation {
            let fetchRequest: NSFetchRequest<WishList> = WishList.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "busStopID == %d", busStopID)
            
            do {
                let existingWishList = try viewContext.fetch(fetchRequest)
                
                if let wishItem = existingWishList.first {
                    // 이미 해당 ID를 가진 항목이 있으면 삭제
                    viewContext.delete(wishItem)
                    showAlert = true
                    alertMessage = "즐겨찾기에서 삭제되었습니다."
                } else {
                    // 해당 ID를 가진 항목이 없으면 추가
                    let newWishList = WishList(context: viewContext)
                    newWishList.busStopName = busStopName
                    newWishList.busStopID = Int32(busStopID)
                    newWishList.nextBusStop = nextBusStop
                    showAlert = true
                    alertMessage = "즐겨찾기에 추가되었습니다."
                }
                
                try viewContext.save() // 변경 내용을 저장합니다
            } catch {
                print("Failed to save wishlist item: \(error)")
            }
        }
    }
    
    
    public func fetchData(for busStopID: Int) {
        DispatchQueue.main.async {
            isLoading = true
        }
        
        guard var urlComponents = URLComponents(string: "http://121.147.206.212/json/arriveApi") else {
            DispatchQueue.main.async {
                isLoading = false
                alertMessage = "잘못된 URL입니다."
                showAlert = true
            }
            return
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "BUSSTOP_ID", value: "\(busStopID)")]
        
        guard let url = urlComponents.url else {
            DispatchQueue.main.async {
                isLoading = false
                alertMessage = "URL 생성에 실패했습니다."
                showAlert = true
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer {
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "데이터를 불러오는 중 오류 발생: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    alertMessage = "받은 데이터가 없습니다."
                    showAlert = true
                }
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                DispatchQueue.main.async {
                    if apiResponse.arriveList.isEmpty {
                        alertMessage = "해당 정류장에 도착 예정인 버스가 없습니다."
                        showAlert = true
                    } else {
                        selectedArrival = apiResponse.arriveList
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertMessage = "JSON 데이터를 파싱하는 중 오류가 발생했습니다: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }.resume()
    }

}
