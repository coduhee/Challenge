//
//  ViewController.swift
//  Challenge
//
//  Created by 김주희 on 3/11/26.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources
import AVFoundation

final class HomeViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    
    
    // MARK: - Properties
    private var sections: [HomeSection] = []
    private var searchViewController: UIViewController
    
    
    // MARK: - UI Components
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.backgroundColor = .systemBackground
        $0.alwaysBounceVertical = true
    }
    
    private let loadingLabel = UILabel().then {
        $0.text = "로딩 중..."
        $0.font = .systemFont(ofSize: 18)
        $0.textColor = .systemGray
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private lazy var searchController: UISearchController = {
        let repository = SearchRepository()
        let searchUseCase = SearchUseCase(repository: repository)
        let searchReactor = SearchReactor(searchUseCase: searchUseCase)
        
        let searchVC = SearchViewController()
        
        searchVC.reactor = searchReactor
        
        searchVC.loadViewIfNeeded()
        
        let controller = UISearchController(searchResultsController: searchVC)
        controller.searchBar.placeholder = "M/V, music, podcast 검색"
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.autocorrectionType = .no // 자동완성 기능 off
        controller.searchBar.returnKeyType = .search
        return controller
    }()
    
    
    // MARK: - Init
    init(reactor: HomeReactor, searchVC: SearchViewController) {
        self.searchViewController = searchVC
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureCollectionView()
    }

    
    // MARK: - Layout
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        // 네비게이션 타이틀
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "music"
        
        // 서치바
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true // 버그 방지
        
        view.addSubview(collectionView)
        view.addSubview(loadingLabel)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        loadingLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    
    // MARK: Create Compositional Layout
    private func createLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // Header
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(70)) // 헤더 높이
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top // 섹션의 맨 위에 배치
            )
            
            // 섹션 0 == 봄
            if sectionIndex == 0 {
                
                // 1. Item
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)
                ) // Group이 주는 공간에 Item을 100% 채움
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                // 2. Group
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85), heightDimension: .absolute(190))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3) // 한 그룹에 아이템 3개 세로 배치
                
                group.interItemSpacing = .fixed(0)
                
                // 3. Section
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered // 중앙 집중 식 자동 페이징
                section.interGroupSpacing = 16
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                
                // 헤더 추가
                section.boundarySupplementaryItems = [header]
                
                return section
                
            } else {
                
                // 1. Item
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                // 2. Group
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(160), heightDimension: .absolute(210)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item]
                )
                
                // 3. Section
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                
                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
    }

    // MARK: - RxDataSources
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<HomeSection>(
        
        // MARK: - 기존 cellForItemAt
        configureCell: { dataSource, collectionView, indexPath, item in
            
            // MARK:  첫 번째 섹션(봄) 일 때 -> 리스트형 셀 사용
            if indexPath.section == 0 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.identifier, for: indexPath) as? ListCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                // 구분선 삽입 로직
                // 1) 3으로 나눈게 2인 경우
                let isThirdIncolumn = (indexPath.item % 3) == 2
                
                // 2) 마지막 아이템인 경우
                let isLastItem = indexPath.item == (dataSource.sectionModels[indexPath.section].items.count - 1)
                
                // 둘중에 하나라도 해당되면 선 숨기기
                let shouldHideSeparator = isThirdIncolumn || isLastItem
                
                cell.configure(with: item, rank: indexPath.item + 1, hideSeparator: shouldHideSeparator)
                
                cell.updatePlayUI(isPlaying: item.previewURL == self.reactor?.currentState.playingURL)
                return cell
                
            // MARK: 나머지 섹션 (여름, 가을, 겨울) 일 때 -> 카드형 셀 사용
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as? CardCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.configure(with: item)
                
                cell.updatePlayUI(isPlaying: item.previewURL == self.reactor?.currentState.playingURL)
                return cell
            }
        },
        
        
        // MARK: - 기존 viewForSupplementaryElementOfKind
        configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            
            guard kind == UICollectionView.elementKindSectionHeader,
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: HomeSectionHeaderView.identifier,
                    for: indexPath
                  ) as? HomeSectionHeaderView else {
                return UICollectionReusableView()
            }
            
            let sectionTitle = dataSource.sectionModels[indexPath.section].title
            header.configure(title: sectionTitle)
            
            return header
        }
    )
    
    
    // MARK: - configureCollectionView
    private func configureCollectionView() {
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.identifier)
        
        // 리스트 컬렉션 뷰 추가
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.identifier)
        
        // 헤더뷰 등록
        collectionView.register(HomeSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeSectionHeaderView.identifier)
    }

    
    // MARK: - Bind
    func bind(reactor: HomeReactor) {
        
        // MARK: - View -> Reactor
        // fetchData
        Observable.just(())
            .map { Reactor.Action.fetchData }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        // playAudio
        collectionView.rx.modelSelected(ContentItem.self)
            .map { Reactor.Action.playMusic($0.previewURL) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        // search
        guard let searchVC = searchController.searchResultsController as? SearchViewController,
        let searchReactor = searchVC.reactor else { return }
        
        searchController.searchBar.rx.text.orEmpty
            .filter { !$0.isEmpty }
            .debounce(.milliseconds(800), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { text in SearchReactor.Action.updateKeyword(text) }
            .bind(to: searchReactor.action)
            .disposed(by: disposeBag)
        
        
        searchController.searchBar.rx.searchButtonClicked
            .asDriver() // 메인스레드 보장
            .drive(with: self) { owner, _ in
                owner.searchController.searchBar.resignFirstResponder()
            }
            .disposed(by: disposeBag)
        
        
        
        // MARK: - Reactor -> View
        // sections 상태 바인딩
        reactor.state
            .map(\.sections)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            // 받아온 섹션 데이터를 통째로 dataSource에게 너미기
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // loading 상태 바인딩
        reactor.state
            .map { !$0.isLoading }
            .distinctUntilChanged() // 상태가 바뀔때만
            .observe(on: MainScheduler.instance)
            .bind(to: loadingLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // error 상태 바인딩
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, message in
                owner.showErrorAlert(message: message)
            }
            .disposed(by: disposeBag)
        
        // 음악 재생 및 재생이미지
        reactor.state.map(\.playingURL)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] playingURL in
                guard let self = self else { return }
                
                // 소리 켜기
                if let urlString = playingURL, let url = URL(string: urlString) {
                    AudioManager.shared.play(url: url)
                }
                
                // 재생 이미지
                for cell in self.collectionView.visibleCells {
                    if let playableCell = cell as? PlayableUICell,
                       let indexPath = self.collectionView.indexPath(for: cell),
                       let item = self.dataSource[indexPath] as? ContentItem {
                        
                        let isPlaying = (item.previewURL == playingURL)
                        playableCell.updatePlayUI(isPlaying: isPlaying)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
