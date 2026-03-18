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

final class ListCollectionViewCell: UICollectionViewCell, PlayableUICell {
    
    static let identifier = "ListCollectionViewCell"
    
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.clipsToBounds = true
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let rankLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .label
        $0.textAlignment = .center
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
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
        $0.spacing = 1
        $0.alignment = .leading
    }
    
    private let ellipsisButton = UIImageView().then {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        $0.image = UIImage(systemName: "ellipsis", withConfiguration: config)
        $0.tintColor = .systemGray
        $0.contentMode = .scaleAspectFit
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = .systemGray5
    }
    
    private let dimView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.3)
        $0.isHidden = true
    }
    
    private let playingIndicator = UIImageView().then {
        $0.image = UIImage(systemName: "waveform")
        $0.tintColor = .white
        $0.isHidden = true
    }
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
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
    private func setupUI() {
        contentView.addSubview(containerView)
        
        [imageView, rankLabel, textStackView, separatorView, ellipsisButton].forEach { containerView.addSubview($0) }
        
        [titleLabel, subtitleLabel].forEach { textStackView.addArrangedSubview($0) }
        
        [dimView, playingIndicator].forEach { imageView.addSubview($0) }
        
        containerView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(-10)
            $0.top.bottom.trailing.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(55)
        }
        
        rankLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(13)
            $0.centerY.equalToSuperview()
        }
        
        textStackView.snp.makeConstraints {
            $0.leading.equalTo(rankLabel.snp.trailing).offset(13)
            $0.trailing.equalTo(ellipsisButton.snp.leading).inset(-10)
            $0.centerY.equalToSuperview()
        }
        
        ellipsisButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
        
        separatorView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(0.7)
            $0.leading.equalTo(imageView.snp.trailing).offset(10)
        }
        
        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        playingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(15)
        }
        
    }
    
    
    func updatePlayUI(isPlaying: Bool) {
            playingIndicator.isHidden = !isPlaying
            dimView.isHidden = !isPlaying
        }
    
    
    // MARK: - Configure
    func configure(with item: ContentItem, rank: Int, hideSeparator: Bool) {
        rankLabel.text = "\(rank)"
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
        imageView.loadImage(from: item.imageURL)

        separatorView.isHidden = hideSeparator
    }
}
