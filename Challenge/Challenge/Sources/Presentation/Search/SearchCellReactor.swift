//
//  SearchCellReactor.swift
//  Challenge
//
//  Created by 김주희 on 3/17/26.
//

import ReactorKit
import RxSwift

final class SearchCellReactor: Reactor {
    
    
    // MARK: - Action
    enum Action {
        case toggleMute
    }
    
    
    // MARK: - Mutation
    enum Mutation {
        case setMuted(Bool)
    }
    
    
    // MARK: - State
    struct State {
        var item: ContentItem
        var isMuted: Bool = true
    }
    
    
    // MARK: - Properties
    let initialState: State
    
    
    // MARK: - Init
    init(item: ContentItem) {
        self.initialState = State(item: item)
    }
    
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .toggleMute:
            let newMutedState = !currentState.isMuted
            return .just(.setMuted(newMutedState))
        }
    }
    
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setMuted(let isMuted):
            newState.isMuted = isMuted
        }
        return newState
    }
}
