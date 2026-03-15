//
//  APIEndpoint.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import Foundation


// MARK: 어떤 term, mediaType으로 요청할지를 url 형태로 만들기

enum APIEndpoint {
    static let baseURL = "https://itunes.apple.com/search"
    
    static func search(term: String, media: String) -> URL? {
        var components = URLComponents(string: baseURL) // 인코딩 기능
        components?.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "media", value: media),
            URLQueryItem(name: "country", value: "KR"),
            URLQueryItem(name: "limit", value: "30")
        ]
        return components?.url
    }
}
