//
//  Search.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources
import AVFoundation


final class SearchViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    
    
    // MARK: - Properties
    private var sections: [HomeSection] = []
    
    // MARK: - UI Components
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.backgroundColor = .systemBackground
        $0.alwaysBounceVertical = true
        $0.contentInsetAdjustmentBehavior = .never // safearea 무시
    }
    
    private let homeButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "house.fill")
        config.baseForegroundColor = .label
        config.background.visualEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        config.background.backgroundColor = .systemBackground.withAlphaComponent(0.05)
        config.background.cornerRadius = 30
        $0.configuration = config
    }
    
    
    // MARK: - Init
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bindUI()
        configureCollectionView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 영상 일시정지
        collectionView.visibleCells.forEach { cell in
            if let videoCell = cell as? SearchCollectionViewCell {
                videoCell.pauseVideo()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 영상 다시재생
        collectionView.visibleCells.forEach { cell in
            if let videoCell = cell as? SearchCollectionViewCell {
                videoCell.playVideo()
            }
        }
    }
    
    
    // MARK: - Layout
    private func setupLayout() {
        view.backgroundColor = .systemBackground
        
        [collectionView, homeButton].forEach { view.addSubview($0) }
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        homeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(18)
            $0.width.height.equalTo(60)
        }
        
    }
    
    
    // MARK: - BindUI
    private func bindUI() {
        // 홈 버튼 Tap
        homeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        
        // MARK: Stretchy Video Effect
        collectionView.rx.contentOffset
            .subscribe(onNext: { [weak self] offset in
                guard let self = self else { return }
                let y = offset.y
                
                // 화면을 맨 위에서 아래로 당기면 y가 음수 됨
                if y < 0 {
                    // 컬렉션 뷰에 보이고 있는 셀들을 전부 확인
                    for cell in self.collectionView.visibleCells {
                        // 뮤직비디오 셀만 찾기
                        if let indexPath = self.collectionView.indexPath(for: cell), indexPath.section == 0 {
                            
                            // 당긴 만큼 얼마나 커질지 비율계산하기
                            let height = cell.bounds.height
                            let scale = 1.0 + (abs(y) / height)
                            
                            // 커질때 맨위에 딱붙어있도록 위치 조정
                            let translation = y / 2.0
                            
                            // 셀에 Transform 적용
                            cell.transform = CGAffineTransform(translationX: 0, y: translation).scaledBy(x: scale, y: scale)
                        }
                    }
                } else {
                    // 다시 아래로 스크롤하면 원래 크기로 돌아감
                    for cell in self.collectionView.visibleCells {
                        if let indexPath = self.collectionView.indexPath(for: cell), indexPath.section == 0 {
                            cell.transform = .identity
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Create Compositional Layout
    func createLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            // Header
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            // 섹션 0 == 뮤직 비디오
            if sectionIndex == 0 {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.55))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 16
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
                
                return section
                
            } else {
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
                
                if sectionIndex == 1 {
                    section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 20, bottom: 20, trailing: 20)
                } else {
                    section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 20, bottom: 80, trailing: 20)
                }
                
                // 헤더 추가
                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
    }
    
    
    // MARK: - RxDataSource
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<HomeSection>(
        
        // MARK: - 기존 cellForItemAt
        configureCell: { dataSource, collectionView, indexPath, item in
            
            // MARK: 뮤직비디오 셀
            if indexPath.section == 0 {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionViewCell.identifier, for: indexPath) as? SearchCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.reactor = SearchCellReactor(item: item)
                return cell
            } else {
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
                
                cell.updatePlayUI(isPlaying: item.previewURL == self.reactor?.currentState.playingURL)
                cell.configure(with: item, rank: indexPath.item + 1, hideSeparator: shouldHideSeparator)
                return cell
            }
        },
        
        
        // MARK: - 기존 viewForSupplementaryElementOfKind
        configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            
            guard kind == UICollectionView.elementKindSectionHeader,
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: HomeSectionHeaderView.identifier,
                    for: indexPath) as? HomeSectionHeaderView else {
                return UICollectionReusableView()
            }
            
            let sectionTitle = dataSource.sectionModels[indexPath.section].title
            header.configure(title: sectionTitle)
            
            return header
        }
    )
    
    
    // MARK: Configure CollectionView
    private func configureCollectionView() {
        collectionView.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: SearchCollectionViewCell.identifier)
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.identifier)
        collectionView.register(HomeSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeSectionHeaderView.identifier)
    }
    
    
    // MARK: - Bind
    func bind(reactor: SearchReactor) {
                
        // MARK: - View -> Reactor
        // 컬레션 뷰 셀 클릭
        collectionView.rx.modelSelected(ContentItem.self)
            .map { Reactor.Action.playMusic($0.previewURL) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        
        // MARK: - Reactor -> View
        // 데이터 삽입
        reactor.state
            .map(\.sections)
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // error 상태 바인딩
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showErrorAlert(message: message)
            })
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
