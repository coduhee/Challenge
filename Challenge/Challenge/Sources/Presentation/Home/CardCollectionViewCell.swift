//
//  HomeCollectionViewCell.swift
//  Challenge
//
//  Created by 김주희 on 3/13/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class CardCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "HomeCollectionViewCell"
    
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.clipsToBounds = true
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
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
        $0.alignment = .fill
        $0.distribution = .fill
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
        
        [imageView, textStackView].forEach { containerView.addSubview($0) }
        
        [titleLabel, subtitleLabel].forEach { textStackView.addArrangedSubview($0) }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
            $0.height.equalTo(imageView.snp.width)
        }
        
        textStackView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview().inset(3)
        }
    }
    
    
    // MARK: - Configure
    func configure(with item: ContentItem) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
        imageView.loadImage(from: item.imageURL)
    }
}


#Preview {
    HomeViewController(reactor: reactor)
}
