import SwiftUI
import CoreData
import Foundation

@main
struct appApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

struct ContentView: View {
    
    // coredata 연동 부분
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: WishList.entity(), sortDescriptors: []) var wishList: FetchedResults<WishList>
    @FetchRequest(entity: WishListOfLine.entity(), sortDescriptors: []) var wishListOfLine: FetchedResults<WishListOfLine>
    @FetchRequest(entity: Item.entity(), sortDescriptors: []) var items: FetchedResults<Item>
    @FetchRequest(entity: LineInfo.entity(), sortDescriptors: []) var lines: FetchedResults<LineInfo>
    ///
    
    @State var showAlert = false
    @State private var busstopName = "" // 사용자로부터 입력 받을 버스 정류장 이름을 저장하는 상태 변수
    @State private var routeNumber = "" // 사용자로부터 입력 받을 노선 번호를 저장하는 상태 변수
    @State private var searchType = 0 // 0: Bus Stop Name, 1: Route Number
    @State private var navigate = false // 네비게이션 트리거 상태 변수

    var body: some View {
        NavigationView {
            VStack {
                Picker("검색 방식", selection: $searchType) {
                    Text("정류장 이름").tag(0)
                    Text("노선 번호").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                TextField(searchType == 0 ? "버스 정류장을 입력하세요" : "노선 번호를 입력하세요", text: searchType == 0 ? $busstopName : $routeNumber)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    )
                    .accentColor(.black)
                    .padding(.horizontal, 10)
                    .keyboardType(.webSearch)
                    .onSubmit {
                        navigate = true
                    }
                NavigationLink(
                    destination: searchDestination(),
                    isActive: $navigate,
                    label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white) // Adjust image color if needed
                            Text("검색")
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                )

                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Spacer()

                        Menu {
                            Button(action: {
                                deleteAllWishListItems()
                            }) {
                                Label("즐겨찾기 전체 삭제", systemImage: "trash.circle")
                            }

                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }

                .navigationBarItems(trailing:
                                        HStack {
                    Spacer()
                    NavigationLink(destination: DBView()) {
                        Text("DB")
                    }
                }
                )
                .navigationTitle(getNavigationTitle())
                .padding()

                List {
                    Section(header: Text(searchType == 0 ? "버스 정류장 즐겨찾기" : "버스 노선 즐겨찾기")) {
                        if searchType == 0 {
                            if wishList.isEmpty {
                                Text("즐겨찾기를 등록해주세요")
                                    .foregroundColor(.gray)
                                    .italic()
                            } else {
                                ForEach(wishList.indices, id: \.self) { index in
                                    let wishItem = wishList[index]
                                    if let name = wishItem.busStopName {
                                        if let nextName = wishItem.nextBusStop {
                                            NavigationLink(destination: busInfoResult(busStopName: name, busStopID: Int(wishItem.busStopID), nextBusStop: nextName)) {
                                                 VStack(alignment: .leading) {
                                                     Text(name)
                                                         .font(.headline)
                                                     Text(nextName)
                                                         .font(.subheadline)
                                                         .foregroundColor(.gray)
                                                 }
                                            }
                                        } else {
                                            Text("Unknown")
                                        }
                                    } else {
                                        Text("Unknown")
                                    }
                                }
                            }
                        } else {
                            if wishListOfLine.isEmpty {
                                Text("즐겨찾기를 등록해주세요")
                                    .foregroundColor(.gray)
                                    .italic()
                            } else {
                                ForEach(wishListOfLine.indices, id: \.self) { index in
                                    let wishLine = wishListOfLine[index]
                                    NavigationLink(destination: LineinfoView(LineID: Int(wishLine.lineID), Linename: wishLine.lineName ?? "", nowbusStopID: nil)) {
                                        Text("\(wishLine.lineName ?? "Unknown") 번 버스")
                                    }
                                }
                            }
                        }
                    }
                }
                // 광고 배너 추가
                  BannerAdView()
                      .frame(width: 320, height: 50)
                      .padding(.top)
            }

        }.onAppear {
            checkForEmptyItems()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("데이터 변경사항 있음"),
                  message: Text("데이터 정보가 변경되었습니다. 정보를 받아오겠습니까?"),
                  primaryButton: .default(Text("네"), action: {
                        fetchBusStopData()
                        fetchBusRouteData()
                  }),
                  secondaryButton: .cancel())
        }
    }

    func deleteAllWishListItems() {
        for item in wishList {
            viewContext.delete(item)
        }
        
        for item in wishListOfLine {
            viewContext.delete(item)
        }
        
        do {
            try viewContext.save()
        } catch {
            // 예외 처리
            print("Failed to delete WishList items: \(error)")
        }
    }

    func checkForEmptyItems() {
        if items.isEmpty || lines.isEmpty {
            showAlert = true
        }
    }

    @ViewBuilder
    private func searchDestination() -> some View {
        if searchType == 0 {
            SearchResultView(busstopName: $busstopName)
        } else {
            SearchLineResultView(busRouteNumber: $routeNumber)
        }
    }

    private func getNavigationTitle() -> String {
        return searchType == 0 ? "정류장으로 검색" : "버스번호로 검색"
    }
}

