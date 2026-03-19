//
//  SearchCollectionViewCell.swift
//  Challenge
//
//  Created by 김주희 on 3/16/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher
import AVFoundation
import ReactorKit
import RxCocoa

final class SearchCollectionViewCell: UICollectionViewCell, View {
    
    static let identifier = "SearchCollectionViewCell"
    
    var disposeBag = DisposeBag()
    
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.clipsToBounds = true
    }
    
    private let subtitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .white.withAlphaComponent(0.8)
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 27, weight: .heavy)
        $0.textColor = .white
        $0.textAlignment = .left
        $0.numberOfLines = 2
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .white.withAlphaComponent(0.9)
        $0.textAlignment = .left
        $0.numberOfLines = 2
    }
    
    private lazy var muteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        $0.tintColor = .white.withAlphaComponent(0.7)
        $0.backgroundColor = .black.withAlphaComponent(0.4)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    // AVPlayer
    private weak var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = contentView.bounds // 영상 크기 일치시키기
    }
    
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        subtitleLabel.text = nil
        descriptionLabel.text = nil
        
        disposeBag = DisposeBag()
    }
    
    
    // MARK: - Layout
    private func setupUI() {
        contentView.addSubview(containerView)
        
        [titleLabel, subtitleLabel, descriptionLabel, muteButton].forEach {
            containerView.addSubview($0) }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.horizontalEdges.equalToSuperview().inset(22)
        }
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(subtitleLabel.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel.snp.top)
            $0.horizontalEdges.equalToSuperview().inset(22)
        }
        
        muteButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(8)
            $0.width.equalTo(45)
            $0.height.equalTo(37)
        }
    }
    
    
    // MARK: - Player Method
    func attachPlayer(_ player: AVPlayer) {
            self.player = player
            
            if self.playerLayer == nil {
                let layer = AVPlayerLayer(player: player)
                layer.videoGravity = .resizeAspectFill
                containerView.layer.insertSublayer(layer, at: 0) // 맨 밑에 깔기
                self.playerLayer = layer
            } else {
                self.playerLayer?.player = player
            }
        }
    
    
    // MARK: - Bind
    func bind(reactor: SearchCellReactor) {
        
        // MARK: View -> Reactor
        // 음소거 버튼 Tap
        muteButton.rx.tap
            .map(\.self).map { Reactor.Action.toggleMute }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        
        // MARK: Reactor -> View
        // 음소거 상태
        reactor.state
            .map { $0.isMuted }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isMuted in
                self?.player?.isMuted = isMuted
                let imageName = isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
                self?.muteButton.setImage(UIImage(systemName: imageName), for: .normal)
            })
            .disposed(by: disposeBag)
        
        // configure
        reactor.state
            .map { $0.item }
            .take(1)
            .subscribe(onNext: { [weak self] item in
                self?.configure(with: item)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Configure
    func configure(with item: ContentItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        subtitleLabel.text = item.subtitle
    }
}
