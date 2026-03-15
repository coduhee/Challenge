//
//  HomeCollecionViewCell.swift
//  Challenge
//
//  Created by 김주희 on 3/14/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ListCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ListCollectionViewCell"
    
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.clipsToBounds = true
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let rankLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.textColor = .label
        $0.textAlignment = .center
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 17)
        $0.textColor = .label
        $0.numberOfLines = 1
    }
    
    private let subtitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 13)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 1
    }
    
    private let textStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .systemGray5
    }
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    
    // MARK: - Layout
    private func configureUI() {
        contentView.addSubview(containerView)
        
        [imageView, rankLabel, textStackView, separatorView].forEach { containerView.addSubview($0) }
        
        [titleLabel, subtitleLabel].forEach { textStackView.addArrangedSubview($0) }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(-10)
            $0.top.bottom.trailing.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        rankLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(13)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(20)
        }
        
        textStackView.snp.makeConstraints {
            $0.leading.equalTo(rankLabel.snp.trailing).offset(13)
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(0.7)
            $0.leading.equalTo(imageView.snp.trailing).offset(10)
        }
    }
    
    
    // MARK: - Configure
    func configure(with item: ContentItem, rank: Int, hideSeparator: Bool) {
        imageView.loadImage(from: item.imageURL)
        
        rankLabel.text = "\(rank)"
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
        separatorView.isHidden = hideSeparator
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
