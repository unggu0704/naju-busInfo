import SwiftUI
import PDFKit

// 기존 PDF 번호와 파일 URL을 매칭하는 Dictionary (폴백용)
var pdfMapping: [String: URL] = [
    "997": URL(string: "https://www.naju.go.kr/contents/10256/0320/areabus_997_0320.pdf")!,
    "998": URL(string: "https://www.naju.go.kr/contents/10256/0320/areabus_998_0320.pdf")!,
    "999": URL(string: "https://www.naju.go.kr/contents/10256/240329/citybus_999.pdf")!,
    "160": URL(string: "https://www.naju.go.kr/contents/10256/240329/citybus_160.pdf")!,
    "161": URL(string: "https://www.naju.go.kr/contents/10256/240329/citybus_161.pdf")!,
    "급행01": URL(string: "https://www.naju.go.kr/contents/9353/231222/citybus_fast01_231227.pdf")!,
    "급행03": URL(string: "https://www.naju.go.kr/contents/10041/bus_3_240610.pdf")!,
    "21": URL(string: "https://www.naju.go.kr/contents/10256/0320/bus_21_0320.pdf")!,
    "22": URL(string: "https://www.naju.go.kr/contents/10256/0320/bus_22_0320.pdf")!,
    "23": URL(string: "https://www.naju.go.kr/contents/10256/0320/bus_23_0320.pdf")!,
    "31": URL(string: "https://www.naju.go.kr/contents/10256/0320/bus_31_0320.pdf")!,
    "32": URL(string: "https://www.naju.go.kr/contents/10256/0320/bus_32_0320.pdf")!,
    "100": URL(string: "https://www.naju.go.kr/contents/10256/0315/citybus_100_0315.pdf")!,
    "101": URL(string: "https://www.naju.go.kr/images/www/citybus/240412/citybus_101_3.pdf")!,
    "200": URL(string: "https://www.naju.go.kr/contents/10256/0320/citybus_200_0320.pdf")!,
    "201": URL(string: "https://www.naju.go.kr/images/www/citybus/240412/citybus_201_2.pdf")!,
    "300": URL(string: "https://www.naju.go.kr/contents/10256/0315/citybus_300_0315.pdf")!,
    "5": URL(string: "https://www.naju.go.kr/contents/9353/230916/citybus_5.pdf")!,
    "6": URL(string: "https://www.naju.go.kr/contents/9353/230916/citybus_6.pdf")!,
    "410": URL(string: "https://www.naju.go.kr/images/www/citybus/240412/citybus_410.pdf")!,
    "411": URL(string: "https://www.naju.go.kr/images/www/citybus/240412/citybus_411.pdf")!,
    "412": URL(string: "https://www.naju.go.kr/images/www/citybus/240412/citybus_412.pdf")!,
    "413": URL(string: "https://www.naju.go.kr/contents/10041/bus_413_240610.pdf")!,
    "500": URL(string: "https://www.naju.go.kr/contents/10041/bus_500_240610.pdf")!,
    "600": URL(string: "https://www.naju.go.kr/contents/10256/0315/citybus_600_0315.pdf")!,
    "601": URL(string: "https://www.naju.go.kr/contents/10256/0320/citybus_601_0320.pdf")!,
    "602": URL(string: "https://www.naju.go.kr/contents/10256/0320/citybus_602_0320.pdf")!,
    "700": URL(string: "https://www.naju.go.kr/contents/10256/0320/citybus_700_0320.pdf")!,
    "701": URL(string: "https://www.naju.go.kr/contents/10256/0320/citybus_701_0320.pdf")!,
    "702": URL(string: "https://www.naju.go.kr/contents/10041/bus_702_240610.pdf")!,
    "7000": URL(string: "https://www.naju.go.kr/contents/10256/0320/citybus_7000_0320.pdf")!,
    "7001": URL(string: "https://www.naju.go.kr/contents/10256/0320/citybus_7001_0320.pdf")!,
    "7002": URL(string: "https://www.naju.go.kr/contents/10256/0320/citybus_7002_0320.pdf")!,
    "셔틀1": URL(string: "https://www.naju.go.kr/contents/10256/240329/citybus_19_2.pdf")!,
    "셔틀2": URL(string: "https://www.naju.go.kr/contents/9353/230916/citybus_20.pdf")!,
    "순환1": URL(string: "https://www.naju.go.kr/contents/10256/0320/circular_1_0320.pdf")!,
    "순환2": URL(string: "https://www.naju.go.kr/contents/10256/0320/circular_2_0320.pdf")!,
    "순환3": URL(string: "https://www.naju.go.kr/contents/10256/0320/circular_3_0320.pdf")!
]

// 간단한 PDF 링크 업데이트 클래스
class PDFLinkUpdater {
    static let shared = PDFLinkUpdater()
    private let jsonURL = "https://raw.githubusercontent.com/UNGGU0704/Naju_busInfo/dev/pdf-links.json"
    
    private init() {
        print("🚀 PDFLinkUpdater 초기화 시작")
        print("📍 JSON URL: \(jsonURL)")
        
        // 앱 시작 시 자동으로 업데이트 시도
        updateLinksIfNeeded()
    }
    
    func updateLinksIfNeeded() {
        print("🔄 PDF 링크 업데이트 확인 중...")
        
        // 마지막 업데이트 시간 확인
        let lastUpdate = UserDefaults.standard.object(forKey: "lastPDFUpdate") as? Date ?? Date.distantPast
        let hoursSinceUpdate = Date().timeIntervalSince(lastUpdate) / 3600
        
        print("⏰ 마지막 업데이트: \(lastUpdate)")
        print("⏱️ 경과 시간: \(hoursSinceUpdate)시간")
        
        // 24시간마다 업데이트
        if hoursSinceUpdate > 24 {
            print("✅ 24시간 경과 - 원격 링크 가져오기 시작")
            fetchRemoteLinks()
        } else {
            print("⏭️ 24시간 미경과 - 캐시 데이터 사용")
            // 캐시된 데이터 로드
            loadCachedLinks()
        }
    }
    
    private func fetchRemoteLinks() {
        print("🌐 원격 JSON 파일 다운로드 시작...")
        
        guard let url = URL(string: jsonURL) else {
            print("❌ 잘못된 JSON URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ 네트워크 오류: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ 데이터 없음")
                return
            }
            
            print("✅ 데이터 수신 완료 - 크기: \(data.count) bytes")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("📋 JSON 파싱 성공")
                    print("🔑 JSON 키: \(json.keys.joined(separator: ", "))")
                    
                    if let links = json["links"] as? [String: String] {
                        print("📦 링크 개수: \(links.count)개")
                        
                        // 새 링크로 pdfMapping 업데이트
                        DispatchQueue.main.async {
                            var updateCount = 0
                            var newCount = 0
                            
                            for (key, urlString) in links {
                                if let url = URL(string: urlString) {
                                    let isNew = pdfMapping[key] == nil
                                    let isUpdated = pdfMapping[key]?.absoluteString != urlString
                                    
                                    pdfMapping[key] = url
                                    
                                    if isNew {
                                        newCount += 1
                                        print("🆕 새 링크 추가: \(key)")
                                    } else if isUpdated {
                                        updateCount += 1
                                        print("♻️ 링크 업데이트: \(key)")
                                    }
                                }
                            }
                            
                            print("📊 업데이트 완료 - 새 링크: \(newCount)개, 변경: \(updateCount)개")
                            print("📊 전체 링크 수: \(pdfMapping.count)개")
                            
                            // 캐시에 저장
                            UserDefaults.standard.set(data, forKey: "cachedPDFLinks")
                            UserDefaults.standard.set(Date(), forKey: "lastPDFUpdate")
                            print("💾 캐시 저장 완료")
                        }
                    } else {
                        print("❌ 'links' 필드를 찾을 수 없음")
                    }
                }
            } catch {
                print("❌ JSON 파싱 오류: \(error)")
            }
        }.resume()
    }
    
    private func loadCachedLinks() {
        print("📂 캐시된 링크 로드 중...")
        
        guard let data = UserDefaults.standard.data(forKey: "cachedPDFLinks") else {
            print("⚠️ 캐시된 데이터 없음")
            return
        }
        
        print("✅ 캐시 데이터 발견 - 크기: \(data.count) bytes")
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let links = json["links"] as? [String: String] {
                
                print("📦 캐시된 링크 개수: \(links.count)개")
                
                var loadCount = 0
                for (key, urlString) in links {
                    if let url = URL(string: urlString) {
                        pdfMapping[key] = url
                        loadCount += 1
                    }
                }
                
                print("✅ 캐시 로드 완료: \(loadCount)개 링크")
            }
        } catch {
            print("❌ 캐시 로드 오류: \(error)")
        }
    }
    
    // 디버깅용 헬퍼 메서드
    func debugPrintCurrentLinks() {
        print("\n=== 현재 PDF 링크 목록 ===")
        print("총 \(pdfMapping.count)개")
        for (key, url) in pdfMapping.sorted(by: { $0.key < $1.key }) {
            print("[\(key)]: \(url.lastPathComponent)")
        }
        print("========================\n")
    }
}

// 기존 PDFViewer 구조체는 거의 그대로 유지
struct PDFViewer: View {
    let selectedPDFNumber: String
    
    @State private var pdfDocument: PDFDocument?

    var body: some View {
        VStack {
            // PDF를 로드하는데 실패
            if pdfDocument == nil {
                Text("죄송합니다 현재 시간표가 제공되지 않는 노선입니다.")
            } else {
                PDFKitRepresentedView(document: pdfDocument!)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            print("\n🎯 PDFViewer 시작 - 노선: \(selectedPDFNumber)")
            
            // PDFLinkUpdater 초기화 (첫 사용 시 자동 업데이트)
            _ = PDFLinkUpdater.shared
            
            if let pdfURL = pdfMapping[selectedPDFNumber] {
                print("✅ PDF URL 발견: \(pdfURL)")
                print("📥 PDF 다운로드 시작...")
                
                // 외부 URL에서 직접 PDF를 로드
                URLSession.shared.dataTask(with: pdfURL) { data, response, error in
                    if let error = error {
                        print("❌ PDF 다운로드 오류: \(error.localizedDescription)")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("📡 HTTP 상태 코드: \(httpResponse.statusCode)")
                    }
                    
                    guard let data = data else {
                        print("❌ PDF 데이터 없음")
                        return
                    }
                    
                    print("✅ PDF 데이터 수신 - 크기: \(data.count) bytes")
                    
                    if let document = PDFDocument(data: data) {
                        DispatchQueue.main.async {
                            self.pdfDocument = document
                            print("✅ PDF 문서 생성 성공 - 페이지 수: \(document.pageCount)")
                        }
                    } else {
                        print("❌ PDF 문서 생성 실패")
                    }
                }.resume()
            } else {
                print("❌ \(selectedPDFNumber) 노선의 PDF 매핑을 찾을 수 없음")
                print("🔍 사용 가능한 노선: \(Array(pdfMapping.keys).sorted())")
                
                // 디버깅: 현재 모든 링크 출력
                PDFLinkUpdater.shared.debugPrintCurrentLinks()
            }
        }
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        print("✅ PDFView 생성 완료")
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
    }
}
