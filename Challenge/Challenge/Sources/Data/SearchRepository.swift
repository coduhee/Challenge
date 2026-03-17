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
        
        switch mediaType {
        case .music:
            mediaString = "music"
        case .musicVideo:
            mediaString = "musicVideo"
        case .podcast:
            mediaString = "podcast"
        }

        
        guard let url = APIEndpoint.search(term: term, media: mediaString) else {
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
