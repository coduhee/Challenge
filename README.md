# 🎵 iTunes Search Challenge

이 프로젝트는 iTunes API를 활용하여 음악, 뮤직비디오, 팟캐스트 등을 검색하고 미리듣기를 제공하는 iOS 애플리케이션입니다. **Clean Architecture**와 **ReactorKit-단방향 MVVM**을 기반으로 설계되었으며, 안정적인 미디어 스트리밍(AVPlayer)과 직관적인 UX를 제공하는 데 중점을 두었습니다.

## 📱 완성 화면 (시연 영상)


https://github.com/user-attachments/assets/a783dc54-61ac-45aa-b251-81e81dbed8de



<br>

## 🏛 프로젝트 아키텍처 및 설계 의사결정

이 프로젝트는 유지보수성과 테스트 용이성을 극대화하기 위해 **Clean Architecture**를 도입했으며, Presentation 계층에는 단방향 데이터 흐름을 강제하는 **ReactorKit**을 적용했습니다.

### 1. 계층 분리 (Layered Architecture)
첨부된 폴더 구조와 같이 역할을 명확히 3개의 계층으로 분리했습니다.
* **Data Layer:** `NetworkManager`, `SearchRepository`, `ItunesResponseDTO` 등을 배치하여 외부 API와의 통신 및 데이터 매핑을 전담합니다.
* **Domain Layer:** `ContentItem`, `FetchHomeContentUseCase`, `SearchUseCase` 등을 배치하여 비즈니스 로직과 엔티티를 정의합니다. 외부 프레임워크에 의존하지 않는 순수한 계층입니다.
* **Presentation Layer:** `Home`, `Search` 도메인별로 폴더를 나누고, UI(View)와 상태 관리(Reactor)를 담당합니다.

### 2. 라이브러리 선택 이유
* **ReactorKit & RxSwift:** 기존 MVVM의 양방향 바인딩으로 인한 상태 관리의 복잡성을 해결하기 위해 도입했습니다. 사용자의 Action과 View의 State를 명확히 분리하여 사이드 이펙트를 최소화했습니다.
* **SnapKit & Then:** 코드로 UI를 작성할 때 가독성을 높이고, 클로저 기반의 직관적인 초기화를 위해 사용했습니다.
* **Kingfisher:** 비동기 이미지 다운로드 및 메모리/디스크 캐싱을 처리하여 컬렉션 뷰 스크롤 성능을 최적화하기 위해 도입했습니다.
* **Alamofire:** `URLSession` 대비 보일러플레이트 코드를 대폭 줄이고, 라우터 패턴(`APIEndpoint`)과 결합하여 네트워크 요청 및 쿼리 파라미터 인코딩을 직관적이고 안전하게 관리하기 위해 사용했습니다.
* **RxDataSources:** 여러 섹션(`HomeSection`)과 다양한 셀 타입(Card, List)이 혼재된 컬렉션 뷰를 선언적으로 바인딩하기 위해 도입했습니다. 데이터 변경 시 수동 업데이트 로직 없이, 자동으로 Diff를 계산하고 애니메이션을 처리해 주어 복잡한 뷰 상태 관리를 간소화했습니다.
* **SnapKit & Then:** 코드로 UI를 작성할 때 가독성을 높이고, 클로저 기반의 직관적인 초기화를 위해 사용했습니다.

<br>

## 💡 핵심 키워드 구현 설명

요구사항 중 다음 3가지 핵심 키워드를 중점적으로 고민하고 구현했습니다.

### 1. 의존성 주입 (Dependency Injection)
`HomeViewController`가 구체적인 데이터 레이어나 타 뷰 컨트롤러에 직접 의존하여 강하게 결합되는 문제를 해결하기 위해 **의존성 주입(DI)**을 적용했습니다.
* `SceneDelegate`를 DI Container처럼 활용하여 앱 진입 시점에 `Repository`, `UseCase`, `Reactor` 및 `UISearchController`를 모두 조립(생성)했습니다.
* 조립된 객체들을 `HomeViewController`의 `init`을 통해 주입함으로써, View는 오직 화면을 그리고 리액터와 바인딩하는 '단일 책임(SRP)'에만 집중할 수 있도록 아키텍처 경계를 명확히 했습니다.

### 2. 추상화 (Abstraction) & 재사용성 (Reusability)
컬렉션 뷰의 여러 셀(Card, List)에서 '재생 중 표시(Indicator)' UI를 업데이트해야 하는 상황에서, 각 셀 타입을 직접 캐스팅(`if let cell as? CardCollectionViewCell`)하는 방식은 '개방-폐쇄 원칙(OCP)'을 위배한다고 판단했습니다.
* 이를 해결하기 위해 `PlayableUICell`이라는 **프로토콜(Protocol)을 선언하여 UI 업데이트 기능을 추상화**했습니다.
* 뷰 컨트롤러에서는 구체적인 셀 타입에 의존하지 않고, 해당 프로토콜을 준수하는 객체인지 검사하여 로직을 처리하도록 다형성을 구현했습니다. 이를 통해 향후 새로운 형태의 셀이 추가되더라도 기존 코드를 수정할 필요가 없는 높은 재사용성을 확보했습니다.

### 3. 사용성 UX (User Experience)
미디어 재생과 관련된 사용자 경험을 극대화하기 위해 다양한 예외 상황을 고려했습니다.
* **AVPlayer 재생 시점:** URL을 받자마자 무작정 `play()`를 호출하지 않고, `AVPlayerItem.Status`를 실시간으로 observe 하다가 `.readyToPlay` 상태가 되는 정확한 시점에 `play`하여 버퍼링 버그를 잡았습니다.
* **영상 레이아웃 수정:** 오토레이아웃이 설정되기 전에 영상이 `play`되어 레이아웃이 0으로 찌그러져 있던 문제를 `contentView.bounds`를 플레이어 레이어에 대입해 버그를 잡았습니다.
* **음소거 버튼 트러블 슈팅:** 비디오 레이어가 UI 컴포넌트를 가리는 문제를 해결하기 위해 `insertSublayer(at: 0)`를 사용하여 비디오를 배경으로 배치했습니다.
* **사운드 오버랩 방지:** 홈 화면과 검색 화면을 넘나들며 곡을 재생할 때 오디오가 겹치지 않도록 싱글톤 패턴의 `AudioManager`를 도입하여 단일 자원(오디오 스피커)을 안정적으로 관리했습니다.

<br>

## ⚠️ 메모리 누수 확인 

### Memory Graph Debugger
* **클로저 순환 참조 해결**
* <img width="1081" height="682" alt="노트 2026  3  16" src="https://github.com/user-attachments/assets/50f4d95e-fee8-4c81-aee6-fc427a44b896" />


### Instruments(Leaks)
* **메모리 누수 없음**
<img width="1476" height="833" alt="스크린샷 2026-03-19 오전 2 05 59" src="https://github.com/user-attachments/assets/9cbbd803-4239-4dda-9b5e-6429fdf52a3f" />


<br>

## 🔥 자율 추가 구현 기능 및 트러블 슈팅

과제 기본 요구사항 외에 앱의 완성도를 높이기 위해 다음과 같은 디테일을 추가했습니다.

* **글로벌 오디오 매니저 (`AudioManager.swift`):** 싱글톤 객체를 생성하여 기존 곡 일시 정지 및 새로운 곡 재생 로직을 중앙 집중화했습니다.
* **재생 상태 시각화 (Play Indicator):** Reactor의 State(`playingURL`)를 구독하고 스크롤 재사용(dequeue) 시점에도 상태를 동기화하여, 현재 재생 중인 음악의 셀에만 파동 애니메이션(Indicator)이 표시되도록 구현했습니다.
* **데이터 예외 처리 (Error Pop-up):** 미리듣기(`previewURL`)가 제공되지 않는 콘텐츠를 탭 할 경우, Reactor단에서 상태를 검사하고 `@Pulse` 속성인 `errorMessage`를 방출하여 자연스럽게 에러 Alert이 노출되도록 구현했습니다. 

<br>

## 📂 File Structure
```text
📦 Challenge
 ┣ 📂 Extensions
 ┃ ┗ 📜 Extensions.swift
 ┣ 📂 Managers
 ┃ ┣ 📜 AudioManager.swift
 ┃ ┗ 📜 Protocols.swift
 ┣ 📂 Resources
 ┗ 📂 Sources
   ┣ 📂 Application
   ┃ ┣ 📜 AppDelegate.swift
   ┃ ┗ 📜 SceneDelegate.swift
   ┣ 📂 Data
   ┃ ┣ 📜 APIEndpoint.swift
   ┃ ┣ 📜 ItunesResponseDTO.swift
   ┃ ┣ 📜 NetworkManager.swift
   ┃ ┗ 📜 SearchRepository.swift
   ┣ 📂 Domain
   ┃ ┣ 📜 ContentItem.swift
   ┃ ┣ 📜 FetchHomeContentUseCase.swift
   ┃ ┣ 📜 HomeSection.swift
   ┃ ┣ 📜 SearchRepositoryType.swift
   ┃ ┗ 📜 SearchUseCase.swift
   ┗ 📂 Presentation
     ┣ 📂 Home
     ┃ ┣ 📜 CardCollectionViewCell.swift
     ┃ ┣ 📜 HomeReactor.swift
     ┃ ┣ 📜 HomeSectionHeaderView.swift
     ┃ ┣ 📜 HomeViewController.swift
     ┃ ┗ 📜 ListCollectionViewCell.swift
     ┗ 📂 Search
       ┣ 📜 SearchCellReactor.swift
       ┣ 📜 SearchCollectionViewCell.swift
       ┣ 📜 SearchReactor.swift
       ┗ 📜 SearchViewController.swift
