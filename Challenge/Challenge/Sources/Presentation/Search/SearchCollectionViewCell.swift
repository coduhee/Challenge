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
    
    private let imageContainerView = UIView().then {
        $0.clipsToBounds = true
    }
    
    // AVPlayer
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    
    private lazy var muteButton = UIButton().then {
        $0.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        $0.tintColor = .white.withAlphaComponent(0.7)
        $0.backgroundColor = .black.withAlphaComponent(0.4)
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = imageContainerView.bounds // 화면 크기 일치시키기
    }
    
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        subtitleLabel.text = nil
        descriptionLabel.text = nil
        
        disposeBag = DisposeBag()
        
        // 비디오 정지하고 메모리 청소
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        playerLayer?.isHidden = true
        
        player?.isMuted = true
        muteButton.setImage(UIImage(systemName: "speaker.slash.fill"), for: .normal)
    }

    
    // MARK: - Layout
    private func setupUI() {
        contentView.addSubview(containerView)
        
        [imageContainerView, titleLabel, subtitleLabel, descriptionLabel, muteButton].forEach {
            containerView.addSubview($0) }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageContainerView.snp.makeConstraints {
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
        
        // Set MV
        player = AVPlayer()
        player?.isMuted = true
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.isHidden = true
        
        if let playerLayer = playerLayer {
            imageContainerView.layer.addSublayer(playerLayer)
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
    
    // video Methods
    func playVideo() {
        player?.play()
    }
    
    func pauseVideo() {
        player?.pause()
    }

    
    // MARK: - Configure
    func configure(with item: ContentItem) {
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        subtitleLabel.text = item.subtitle
        
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        playerLayer?.isHidden = true
        
        if let previewURLString = item.previewURL,
           let previewURL = URL(string: previewURLString) {
            
            let newPlayItem = AVPlayerItem(url: previewURL)
            player?.replaceCurrentItem(with: newPlayItem)
            
            // MARK: 무한재생
            // 영상 종료 시점 구독
            NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime, object: newPlayItem)
                .subscribe(onNext: { [weak self] _ in
                    self?.player?.seek(to: .zero) // 영상 맨앞으로
                    self?.player?.play()
                })
                .disposed(by: disposeBag)
            
            // MARK: ReadyToPlay일때 재생
            newPlayItem.rx.observe(AVPlayerItem.Status.self, "status")
                .compactMap { $0 }
                .filter { $0 == .readyToPlay }
                .take(1)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    self?.playerLayer?.isHidden = false
                    self?.player?.play()
                })
                .disposed(by: disposeBag)
            }
    }
}
