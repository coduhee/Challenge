//
//  SearchRepositoryType.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import Foundation
import RxSwift

protocol SearchRepositoryType {
    func fetchContent(term: String, mediaType: MediaType) -> Single<[ContentItem]>  // 컨텐츠 검색
}
