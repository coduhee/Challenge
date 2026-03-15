//
//  HomeSectionHeaderView.swift
//  Challenge
//
//  Created by 김주희 on 3/14/26.
//

import UIKit
import SnapKit
import Then

final class HomeSectionHeaderView: UICollectionReusableView {
    
    static let identifier = "HomeSectionHeaderView"
    
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 25)
        $0.textColor = .label
    }
    
    private let chevronImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        $0.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        $0.tintColor = .systemGray
        $0.contentMode = .scaleAspectFit
    }
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    
    // MARK: - Layout
    private func configureUI() {
        addSubview(titleLabel)
        addSubview(chevronImageView)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview().offset(30)
        }
        
        chevronImageView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing)
            $0.top.equalTo(titleLabel.snp.top).offset(2)
            $0.width.height.equalTo(23)
        }
    }
    
    
    // MARK: - Configure
    func configure(title: String) {
        titleLabel.text = title
    }
}


@available (iOS 17.0, *)
#Preview {
    let networkManager = NetworkManager()
    let repository = SearchRepository(networkManager: networkManager)
    let useCase = FetchHomeContentUseCase(repository: repository)
    let reactor = HomeReactor(fetchHomeContentsUseCase: useCase)
    HomeViewController(reactor: reactor)
}
