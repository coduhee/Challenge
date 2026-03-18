//
//  SearchRepository.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import Foundation
import RxSwift

final class SearchRepository: SearchRepositoryType {
    
    // MARK: error
    enum NetworkError: Error {
        case invalidURL
    }
    
    
    // MARK: - fetchContent
    func fetchContent(term: String, mediaType: MediaType) -> Single<[ContentItem]> {
        let mediaString: String
        let countryString: String
        let limitString: String
        
        switch mediaType {
        case .music:
            mediaString = "music"
            countryString = "KR"
            limitString = "10"
        case .musicVideo:
            mediaString = "musicVideo"
            countryString = "US"
            limitString = "1"
        case .podcast:
            mediaString = "podcast"
            countryString = "KR"
            limitString = "10"
        }

        
        guard let url = APIEndpoint.search(term: term, media: mediaString, country: countryString, limit: limitString) else {
            return .error(NetworkError.invalidURL)
        }
        
        // NetworkManager로 요청을 보내 데이터를 받아옴
        return NetworkManager.shared.request(url)
            .map { (response: ItunesResponseDTO) in
                // DTO -> entity로 바꿔줌
                response.results.map { $0.toEntity(mediaType: mediaType) }
            }
    }
}
