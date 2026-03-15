//
//  SearchRepository.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import Foundation
import RxSwift

final class SearchRepository: SearchRepositoryType {
    
    private let networkManager: NetworkManager
    
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    
    // MARK: - fetchMusic
    func fetchMusic(term: String) -> Single<[ContentItem]> {
        // API Endpoint 이용해서 url 생성하기
        guard let url = APIEndpoint.search(term: term, media: "music") else {
            return .error(NSError(domain: "InvalidURL", code: -1))
        }
        
        // NetworkManager로 요청을 보내 데이터를 받아옴
        return networkManager.request(url)
            .map { (response: ItunesResponseDTO) in
                // DTO -> entity로 바꿔줌
                response.results.map { $0.toEntity(mediaType: .music) }
            }
    }
    
    
    // MARK: - fetchContent
    func fetchContent(term: String, mediaType: MediaType) -> Single<[ContentItem]> {
        let mediaString: String
        
        switch mediaType {
        case .music:
            mediaString = "music"
        case .movie:
            mediaString = "movie"
        case .podcast:
            mediaString = "podcast"
        }
        
        guard let url = APIEndpoint.search(term: term, media: mediaString) else {
            return .error(NSError(domain: "InvalidURL", code: -1))
        }
        
        // NetworkManager로 요청을 보내 데이터를 받아옴
        return networkManager.request(url)
            .map { (response: ItunesResponseDTO) in
                // DTO -> entity로 바꿔줌
                response.results.map { $0.toEntity(mediaType: mediaType) }
            }
    }
}
