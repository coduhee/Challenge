//
//  SearchRepositoryType.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import Foundation
import RxSwift

protocol SearchRepositoryType {
    func fetchMusic(term: String) -> Single<[ContentItem]>  // 음악 검색    // Single: 데이터를 방출하거나, 에러를 주거나
    func fetchContent(term: String, mediaType: MediaType) -> Single<[ContentItem]>  // 컨텐츠 검색
}
