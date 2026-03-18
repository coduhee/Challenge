//
//  Untitled.swift
//  Challenge
//
//  Created by 김주희 on 3/15/26.
//

import Foundation
import RxSwift

final class SearchUseCase {
    
    private let repository: SearchRepositoryType
    
    init(repository: SearchRepositoryType) {
        self.repository = repository
    }
    
    // musicVideo, podcast 동시에(zip) 데이터 호출
    func execute(keyword: String) -> Single<[HomeSection]> {
        let musicVideo = repository.fetchContent(term: keyword, mediaType: .musicVideo)
        let music = repository.fetchContent(term: keyword, mediaType: .music)
        let podcast = repository.fetchContent(term: keyword, mediaType: .podcast)
        
        return Single.zip(musicVideo, music, podcast) { musicVideoItems, musicItems, podcastItems in
                return [
                HomeSection(title: "🔥 지금 가장 핫한 \(keyword) M/V", items: musicVideoItems),
                HomeSection(title: "\(keyword) 인기 차트", items: musicItems),
                HomeSection(title: "\(keyword), 팟캐스트로 딥다이브", items: podcastItems)
            ]
        }
    }
}
