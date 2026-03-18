//
//  ItunesResponseDTO.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import Foundation


struct ItunesResponseDTO: Decodable {
    let resultCount: Int // ex: 10개
    let results: [ItunesItemDTO] // ex: 노래 데이터 10개 뭉치 배열
}

struct ItunesItemDTO: Decodable {
    let trackId: Int?
    let collectionId: Int?
    let trackName: String?
    let collectionName: String?
    let artistName: String?
    let artworkUrl60: String?
    let artworkUrl100: String?
    var artworkUrl300: String? {
        return artworkUrl100?.replacingOccurrences(of: "100x100", with: "300x300")
    }
    let longDescription: String?
    let shortDescription: String?
    let primaryGenreName: String?
    let previewUrl: String?
}


// DTO -> ContentItem
extension ItunesItemDTO {
    func toEntity(mediaType: MediaType) -> ContentItem {
        ContentItem(
            id: trackId ?? collectionId ?? 0,
            title: trackName ?? collectionName ?? "제목 없음",
            subtitle: artistName ?? "아티스트 없음",
            imageURL: artworkUrl300 ?? artworkUrl100 ?? artworkUrl60 ?? "",
            description: longDescription ?? shortDescription ?? primaryGenreName ?? "설명 없음",
            mediaType: mediaType,
            previewURL: previewUrl
        )
    }
}
