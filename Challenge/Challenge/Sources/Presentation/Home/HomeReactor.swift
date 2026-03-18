//
//  HomeViewModel.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//
 
import Foundation
import UIKit
import RxSwift
import ReactorKit

final class HomeReactor: Reactor {
    
    
    // MARK: - Action
    enum Action {
        case fetchData
    }
    
    
    // MARK: - Mutation
    enum Mutation {
        case setSections([HomeSection])
        case setLoading(Bool)
        case setErrorMessage(String?)
    }
    
    
    // MARK: - State
    struct State {
        var sections: [HomeSection] = []
        var isLoading: Bool = false
        @Pulse var errorMessage: String?
    }
    
    
    // MARK: - Properties
    let initialState = State()
    private let fetchHomeContentsUseCase: FetchHomeContentUseCase
    
    
    // MARK: - Init
    init(fetchHomeContentsUseCase: FetchHomeContentUseCase) {
        self.fetchHomeContentsUseCase = fetchHomeContentsUseCase
    }
    
    
    // MARK: - Mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchData:
            return fetchHomeSections()
        }
    }
    
    
    // MARK: - Reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setSections(let sections):
            newState.sections = sections
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
}


// MARK: - extension
private extension HomeReactor {
    
    func fetchHomeSections() -> Observable<Mutation> {
        return Observable.concat([ // 순차적으로 작업 실행
            
            // 1. 로딩 on
            .just(.setLoading(true)),
            
            // 2. UseCase한테 데이터 가져오도록 시킴
            fetchHomeContentsUseCase.execute()
                .asObservable()
                .map { sections in
                    // 음악 리스트 가져오면 Sections 세팅
                    Mutation.setSections(sections)
                }
                .catch { error in
                    // 에러 발생시 에러 메세지 세팅
                    return .just(.setErrorMessage(error.localizedDescription)) // 스트림이 박살났기때문에 .just
                },
            
            // 3. 로딩 off
                .just(.setLoading(false))
        ])
    }
}
