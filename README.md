<p align="center">
   <img width="200" src="app/Assets.xcassets/AppIcon.appiconset/1024.png" alt="APP Logo"></p>
   
 # <p align="center">나주시 버스 </p>
<p align="center">
   <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.8-orange.svg?style=flat" alt="Swift 5.8">
   </a>
   <img src="https://img.shields.io/badge/iOS-17%2B-brightgreen.svg?style=flat" alt="iOS 17+ Compatible">

<br>
<a href="https://apps.apple.com/kr/app/나주시-버스/id6459411077">
   <img src="https://www.iphones.ru/wp-content/uploads/2010/08/App_Store_Badge_EN1-560x189.png" alt="나주시 버스" width="200"/>
</a>
</p>


# 나주 버스(Naju Bus)
나주 버스 정보를 제공하는 어플로써 버스 정류장 및 노선을 검색하고 버스 도착까지 남은 시간과 노선의 현재 위치를 알려주는 기능을 제공합니다.

## :rocket: 배포(Deploy)

https://apps.apple.com/kr/app/나주시-버스/id6459411077

## :dart: 기능(Features)

- [x] ℹ️ 정류장 데이터 부착
- [x] ℹ️ 정류장 검색
- [x] ℹ️ 도착 시간 제공
- [x] ℹ️ 즐겨 찾기 기능
- [x] ℹ️ 디자인 개선
- [x] ℹ️ 노선 정보 제공
- [x] ℹ️ 노선별 버스 시간표 제공
- [x] ℹ️ 노선 검색 제공
- [x] ℹ️ AdMob 추가 

## :black_square_button: 사용(Usage)
| 메인 화면 | 버스 정보 |
| :---: | :---: |
| <img src = "img/iphone14 plus/newbusmain.png" width="200" align="center"> | <img src="img/iphone14 plus/busStopInfo.png" width="200" align="center"> |
| **노선 정보** | **현재 위치** |
| <img src="img/iphone14 plus/linesearch.png" width="200" align="center"> | <img src="img/iphone14 plus/busLineInfo.png" width="200" align="center"> |

## :white_check_mark: 업데이트 기록 (Update)

### 1.5
_(24. 11. 11)_
- Google Admob 추가
- 로딩 화면 추가
- Dynamic island에서 UI 깨짐 현상 수정
- 버스 시간표 링크 갱신


### 1.4
_(24. 07. 09)_
- **노선 검색 기능 추가**
- 노선 즐겨찾기 기능 추가
- 예외 처리에 따른 사용자 view 제공
- 네트워크 감지 코드 추가
- 잘못된 시간표를 수정
- 서비스 개선 

### 1.3
_(24. 03. 19)_
- 즐겨찾기 Button 클릭시 alert창이 안보이는 버그를 해결 
- 노선 정보 제공에서 버스 시간표 보기 기능 추가 
  - _제공되는 노선 (99x, 16x, 1xx, 2xx, 4xx, 5xx, 70xx)_
- 종점 같은 다음 정류장이 없을때 표시 형식 변경
- API 정보가 없을 경우의 UI 변경
  
### 1.2
_(23. 12. 05)_
- 다크모드에서 특정 UI가 안보이는 버그 해결 
- 노선 정보 새로고침시 화면이 고정되지 않음 
- 즐겨찾기 항목에서 정류장의 방향 정보가 추가 

### 1.1
_(23. 10. 08)_
- 231002 나주시 버스 노선 전면 개편 대응
  - *광역버스 추가(161번...)*
  - *999번 노선 분리(997번 ,998번...)*
  - *그외 등등...*
    
### 1.0.1 
_(23. 08. 12)_
- 어플 정보 수정 

### 1.0 
_(23. 08. 10)_
- 최초 배포 

## 파일(File)

#### `Main View.swift`
- 앱 실행시 보이는 메인 화면입니다. 
  버스 정류장 또는 노선 정보를 검색하는 기능을 가지고 있습니다.
#### `searchBus.swift`
- 정류장 정보를 검색하는 기능을 가지고 있습니다.
#### `searchResultView.swift`
- 버스 정류장 이름을 기반으로 CoreData에서 정류장 정보를 검색하고 
  해당 정류장의 도착 정보를 표시하는 기능을 가지고 있습니다.
#### `searchLineResultView.swift`
- 적절한 노선 정보를 coredata에서 불러와 표시합니다.
#### `LineinfoView.swift`
- 해당 노선이 지나가는 모든 버스 정류장을 보여줍니다. 
  추가적으로 해당 노선이 현재 어디 있는지 또한 보여줍니다.
#### `PDFViewer.swift`
- 검색된 노선의 버스 시간표를 web에서 찾아와 PDF로 저장 후 사용자에게 표시합니다.
#### `BannerAdView.swift`
- 광고 배너를 보여줍니다.
#### `LoadingView.swift`
- 데이터를 불러올 때 로딩하는 화면을 보여줍니다.
#### `NetworkMonitor.swift`
- 모든 Cycle에 있어 네트워크 연결을 감지합니다.
#### `DB.swift`
- CoreData의 저장, 삭제 기능을 가지고 있습니다.
#### `DB view.swift`
- CoreData에서 가져온 정류소 정보를 표시합니다.
  DB.swift의 생성 삭제 기능을 제어합니다.
#### `PersistenceController.swift`
- CoreData를 설정하고 영구 저장소를 로드합니다.
#### `AppDelegate.swift`
- 시스템 상호작용 파일
- Google AdMob 설정
#### `app.xcdatamodeld`
- CoreData의 저장소입니다.

## 기여(Contributing)
Contributions are very welcome 🙌 

기여는 누구나 환영입니다. 🙌


## License
_MIT License_
