//
//  FetchHomeContentUseCase.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import Foundation
import RxSwift

final class FetchHomeContentUseCase {
    
    private let repository: SearchRepositoryType
    
    init(repository: SearchRepositoryType) {
        self.repository = repository
    }
    
    // 계절별로 동시에(zip) 데이터 호출
    func execute() -> Single<[HomeSection]> {
        let spring = repository.fetchMusic(term: "봄")
        let summer = repository.fetchMusic(term: "여름")
        let autumn = repository.fetchMusic(term: "가을")
        let winter = repository.fetchMusic(term: "겨울")
        
        return Single.zip(spring, summer, autumn, winter) { springItems, summerItems, autumnItems, winterItems in
            return [
                HomeSection(title: "봄, 들어봄", items: springItems),
                HomeSection(title: "여름, 귀를 열음", items: summerItems),
                HomeSection(title: "Fall in Fall", items: autumnItems),
                HomeSection(title: "겨울의 결", items: winterItems)
            ]
        }
    }
}
