//
//  HomeSection.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import Foundation
import RxDataSources

// MARK: 홈 화면 섹션 모델
struct HomeSection {
    let title: String
    var items: [ContentItem]
}


// MARK: - RxDataSources가 읽을 수 있도록 extension 추가
extension HomeSection: SectionModelType {
    typealias Item = ContentItem
    
    init(original: HomeSection, items: [Item]) {
        self = original
        self.items = items
    }
}


extension HomeSection: Equatable {}
