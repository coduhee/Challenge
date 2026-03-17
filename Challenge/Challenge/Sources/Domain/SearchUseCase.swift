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
    
    // movie, podcast 동시에(zip) 데이터 호출
    func execute(keyword: String) -> Single<[HomeSection]> {
        let movie = repository.fetchContent(term: keyword, mediaType: .movie)
        let podcast = repository.fetchContent(term: keyword, mediaType: .podcast)
        
        return Single.zip(movie, podcast) { movieItems, podcastItems in
                return [
                HomeSection(title: "🍿 \(keyword), 팝콘과 함께", items: movieItems),
                HomeSection(title: "🎧 \(keyword), 팟캐스트로", items: podcastItems)
            ]
        }
    }
}
