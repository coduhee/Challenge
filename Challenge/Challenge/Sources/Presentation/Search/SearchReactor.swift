//
//  SearchReactor.swift
//  Challenge
//
//  Created by 김주희 on 3/15/26.
//

import Foundation
import UIKit
import RxSwift
import ReactorKit

final class SearchReactor: Reactor {
    
    
    // MARK: - Action
    enum Action {
        case updateKeyword(String)
        case playMusic(String?)
    }
    
    
    // MARK: - Mutation
    enum Mutation {
        case setSections([HomeSection])
        case setErrorMessage(String?)
        case setPlayingURL(String)
    }
    
    
    // MARK: - State
    struct State {
        var sections: [HomeSection] = []
        @Pulse var errorMessage: String?
        var playingURL: String?
    }
    
    
    // MARK: - Properties
    let initialState: State
    private let searchUseCase: SearchUseCase
    
    
    // MARK: - Init
    init(searchUseCase: SearchUseCase) {
        self.searchUseCase = searchUseCase
        self.initialState = State()
    }
    
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateKeyword(let keyword):
            // 검색어 비어있을때
            if keyword.isEmpty {
                return .just(.setSections([]))
            }
            // 검색어가 있으면 API통신 시작
            return fetchSearchSections(keyword: keyword)
            
        case .playMusic(let url):
            guard let url = url, !url.isEmpty else {
                // URL이 없으면 error 팝업
                return .just(.setErrorMessage("미리듣기를 제공하지 않는 콘텐츠입니다."))
            }
            return .just(.setPlayingURL(url))
        }
    }
    
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        case .setSections(let sections):
            newState.sections = sections
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
            
        case .setPlayingURL(let url):
            newState.playingURL = url
        }
        return newState
    }
    
}


// MARK: - extension
private extension SearchReactor {
    func fetchSearchSections(keyword: String) -> Observable<Mutation> {
        
        return searchUseCase.execute(keyword: keyword)
                .asObservable()
                .map { sections in
                    Mutation.setSections(sections)
                }
                .catch { error in
                    return .just(.setErrorMessage(error.localizedDescription))
                }
    }
}

