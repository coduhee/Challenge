//
//  NetworkManager.swift
//  Challenge
//
//  Created by 김주희 on 3/12/26.
//

import Foundation
import Alamofire
import RxSwift

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func request<T: Decodable>(_ url: URL) -> Single<T> {
        return Single.create { single in
            let request = AF.request(url)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let data):
                        single(.success(data))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            // 요청 취소
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
