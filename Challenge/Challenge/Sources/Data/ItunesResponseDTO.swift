//
//  ItunesResponseDTO.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import Foundation


struct ItunesResponseDTO: Decodable {
    let resultCount: Int // ex: 30개
    let results: [ItunesItemDTO] // ex: 노래 데이터 30개 뭉치 배열
}

struct ItunesItemDTO: Decodable {
    let trackId: Int?
    let collectionId: Int?
    let trackName: String?
    let collectionName: String?
    let artistName: String?
    let artworkUrl100: String?
    var artworkUrl600: String? {
        return artworkUrl100?.replacingOccurrences(of: "100x100", with: "600x600")
    }
    let longDescription: String?
    let shortDescription: String?
    let primaryGenreName: String?
}


// DTO -> ContentItem
extension ItunesItemDTO {
    func toEntity(mediaType: MediaType) -> ContentItem {
        ContentItem(
            id: trackId ?? collectionId ?? 0,
            title: trackName ?? collectionName ?? "제목 없음",
            subtitle: artistName ?? "아티스트 없음",
            imageURL: artworkUrl600 ?? "",
            description: longDescription ?? shortDescription ?? primaryGenreName ?? "설명 없음",
            mediaType: mediaType
        )
    }
}
