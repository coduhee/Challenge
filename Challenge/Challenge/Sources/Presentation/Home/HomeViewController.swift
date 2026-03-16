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


final class HomeViewController: UIViewController, View {
    
    var disposeBag = DisposeBag()
    
    
    // MARK: - Properties
    private var sections: [HomeSection] = []
    
    
    // MARK: - RxDataSources
    private let dataSource = RxCollectionViewSectionedReloadDataSource<HomeSection>(
        
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
                return cell
                
            // MARK: 나머지 섹션 (여름, 가을, 겨울) 일 때 -> 카드형 셀 사용
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionViewCell.identifier, for: indexPath) as? CardCollectionViewCell else {
                    return UICollectionViewCell()
                }
                
                cell.configure(with: item)
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
    
    private let searchController = UISearchController(searchResultsController: nil).then {
        $0.searchBar.placeholder = "영화, 팟캐스트 검색"
        $0.obscuresBackgroundDuringPresentation = false
        $0.searchBar.autocorrectionType = .no // 자동완성 기능 off
        $0.searchBar.returnKeyType = .search
    }
    
    
    // MARK: - Init
    init(reactor: HomeReactor) {
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
        configureSearchBar()
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
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.85), heightDimension: .absolute(200))
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
    
    
    // MARK: - configureCollectionView
    private func configureCollectionView() {
        collectionView.delegate = self
        
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: CardCollectionViewCell.identifier)
        
        // 리스트 컬렉션 뷰 추가
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.identifier)
        
        // 헤더뷰 등록
        collectionView.register(HomeSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeSectionHeaderView.identifier)
    }
    
    // MARK: configureSearchBar
    private func configureSearchBar() {
        searchController.searchBar.delegate = self
    }
    
    
    // MARK: - Bind
    func bind(reactor: HomeReactor) {
        
        // MARK: View -> Reactor
        // viewDidLoad
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        // MARK: Reactor -> View
        // sections 상태 바인딩
        reactor.state
            .map(\.sections)
            .observe(on: MainScheduler.instance)
            // 받아온 섹션 데이터를 통째로 dataSource에게 너미기
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        // loading 상태 바인딩
        reactor.state
            .map(\.isLoading)
            .distinctUntilChanged() // 상태가 바뀔때만
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                self?.loadingLabel.isHidden = !isLoading
            })
            .disposed(by: disposeBag)
        
        // error 상태 바인딩
        reactor.state
            .compactMap(\.errorMessage)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showErrorAlert(message: message)
                print("에러 메세지: \(message)")
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - Extension

// MARK: -- UICollectionView 델리게이트
extension HomeViewController: UICollectionViewDelegate { }


// MARK: -- UISearchBar 델리게이트
extension HomeViewController: UISearchBarDelegate {
    
    // 검색버튼 눌렀을때
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" // 양 끝 공백 삭제
        
        guard !keyword.isEmpty else { return } // 텅 빈 검색어 -> 함수 종료
        
        searchBar.resignFirstResponder() // 검색 버튼 누르면 키보드 내려감
    }
}


@available(iOS 17.0, *)
#Preview {
    let networkManager = NetworkManager()
    let repository = SearchRepository(networkManager: networkManager)
    let useCase = FetchHomeContentUseCase(repository: repository)
    let reactor = HomeReactor(fetchHomeContentsUseCase: useCase)
    HomeViewController(reactor: reactor)
}

