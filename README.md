![파란색 그라데이션 헤더 배너 (1)](https://github.com/user-attachments/assets/f7dad3f2-0266-404c-b106-de506ab6b73f)

|앱 & 팀 이름|Hydor & 효도르 |
|:--:|:--|
|로고|<img width="70" alt="" src="https://github.com/user-attachments/assets/2a23f3a6-14d9-4fbb-8ce1-304a1c8b5032"> |
|기간|2025. 03 ~ 2025. 06|
|수상|인하대 컴퓨터공학과 졸업 캡스톤 우수상|
|참여 인원|3명(iOS 개발 1명 + BE 1명 + AI/Embeded 1명)|
|기술 스택|SwiftUI, Alamofire, FCM, AVKit, Photos, Kingfisher, AWS S3|
|아키텍처|MVVM+C, 클린 아키텍처|

## 🔵 기획 의도
- SKT,LG,KT,NAVER 등 대기업에서 혼자 사는 노부모를 위해 자사 기기를 이용한 AI 서비스를 제공하고 있습니다.
- 하지만, 이러한 서비스는 국가 사업과 연관되어, 노부모들의 고독사 방지를 중점으로 운영합니다.
- Hyodor는 단순 고독사 방지를 목적이 아닌 지속적인 가족 유대감을 형성하여 같이 있는 듯한 사용자 경험을 주기 위해 기획했습니다.
- 이는 곧 현실적인 여건으로 같이 살지는 못하지만, 끈끈한 유대를 이어가고 싶은 가정에게 좋은 서비스를 제공한다고 생각합니다.

## 🔵 팀원 소개
|<img src="https://avatars.githubusercontent.com/u/84498457?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/61345151?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/48996852?v=4" width="150" height="150"/>|
|:-:|:-:|:-:|
|김상준(iOS,팀장)<br/>[@kimsangjunzzang](https://github.com/kimsangjunzzang)|이재훈(BE)<br/>[@dlwogns](https://github.com/dlwogns)|민창기(AI,Embeded)<br/>[@min000914](https://github.com/min000914)|

## 🔵 기술 스택

### **Architecture**
- **Clean Architecture**: Domain, Data, Presentation 계층 분리
- **MVVM Pattern**: SwiftUI와 결합한 반응형 아키텍처
- **Coordinator Pattern**: 화면 전환 및 네비게이션 관리

### **Framework & Libraries**
- **SwiftUI**: 선언적 UI 프레임워크
- **Alamofire**: 네트워킹 라이브러리
- **Firebase**: FCM 푸시 알림
- **AVKit**: 비디오 플레이어
- **Photos**: 사진 라이브러리 접근

## 🔵 프로젝트 구조
```
Hyodor/
├── 📁 Application/           # 앱 진입점
├── 📁 Core/                  # 공통 유틸리티
├── 📁 Domain/                # 비즈니스 로직
│   ├── Entities/            # 도메인 엔티티
│   ├── UseCases/           # 비즈니스 유스케이스
│   └── Repositories/       # 리포지토리 인터페이스
├── 📁 Data/                  # 데이터 계층
│   ├── Models/             # 데이터 모델
│   ├── Repositories/       # 리포지토리 구현체
│   └── Services/           # 네트워크/로컬 서비스
└── 📁 Presentation/          # UI 계층
    ├── Home/               # 홈 화면
    ├── Calendar/           # 캘린더
    ├── SharedAlbum/        # 공유 앨범
    ├── Alert/              # 알림
    └── Components/         # 재사용 컴포넌트
```

## 🔵. 주요 기능
### 1. 노부모 일정 관리 기능
보호자가 앱을 이용해 스케줄과 음성 메모를 등록할 경우 디바이스에서 해당 시간에 노부모에게 일정 알림을 전달하고,전달된 음성 파일을 재생합니다.

### 2. 가족 공유 앨범 기능
등록된 보호자들이 같이 사용할 수 있는 공유 앨범으로 앨범에 업로드된 사진은 디바이스에 보여져, 노부모가 즉각적으로 확인할 수 있습니다.

### 3. 이상 현상 감지 알림
인디바이스에 장착된 웹캠에서 낙상 감지 혹은 장시간 미움직임 같은 이상 현상이 감지된경우 즉각적으로 보호자에 FCM을 이용해 알림과 영상을 전송합니다.

## 🔵 주요 구현 사항

### Clean Architecture 적용
```swift
// UseCase 예시
protocol GetDisplayedSchedulesUseCase {
    func execute() -> [Schedule]
}

class GetDisplayedSchedulesUseCaseImpl: GetDisplayedSchedulesUseCase {
    private let scheduleRepository: ScheduleRepository
    
    func execute() -> [Schedule] {
        return scheduleRepository.getUpcomingSchedules(limit: 4)
    }
}
```

### SwiftUI + MVVM
```swift
@Observable
class HomeVM {
    var notifications: [NotificationData] = []
    var selectedSchedule: Schedule? = nil
    
    private let getLatestNotificationsUseCase: GetLatestNotificationsUseCase
    
    func getLatestNotifications() {
        notifications = getLatestNotificationsUseCase.execute()
    }
}
```

### Alamofire 네트워킹
```swift
func requestPresignedURLs(imageInfos: [ImageUploadRequestDTO]) async throws -> [PresignedURLResponseDTO] {
    return try await session.request(
        url,
        method: .post,
        parameters: imageInfos,
        encoder: JSONParameterEncoder.default
    )
    .validate()
    .serializingDecodable([PresignedURLResponseDTO].self)
    .value
}
```
## 🔵 기술적 도전 (기술 블로그)
- [SwiftUI에서 느린 사진 업로드 문제 해결하기](https://kimsangjunzzang.tistory.com/82)
- [SplashView롤 UX 개선하기](https://kimsangjunzzang.tistory.com/90)
- [API 호출 대신 이미지 캐싱으로 성능 최적화 하기](https://kimsangjunzzang.tistory.com/91)
