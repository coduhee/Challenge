//
//  ContentItem.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import Foundation

// MARK: 앱 전체에서 공통으로 쓸 모델
struct ContentItem {
    let id: Int
    let title: String
    let subtitle: String
    let imageURL: String
    let description: String
    let mediaType: MediaType
    let previewURL: String?
}

enum MediaType {
    case music
    case musicVideo
    case podcast
}
