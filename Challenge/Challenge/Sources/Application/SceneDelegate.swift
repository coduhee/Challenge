//
//  SceneDelegate.swift
//  Challenge
//
//  Created by 김주희 on 3/11/26.
//

import UIKit
import ReactorKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 의존성 생성
        let repository = SearchRepository()
        let fetchHomeContentsuseCase = FetchHomeContentUseCase(repository: repository)
        let homereactor = HomeReactor(fetchHomeContentsUseCase: fetchHomeContentsuseCase)
        
        let searchUseCase = SearchUseCase(repository: repository)
        let searchReactor = SearchReactor(searchUseCase: searchUseCase)
        
        let searchVC = SearchViewController()
        searchVC.reactor = searchReactor
        
        let searchController = UISearchController(searchResultsController: searchVC)
        searchController.searchBar.placeholder = "M/V, music, podcast 검색"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocorrectionType = .no // 자동완성 기능 off
        searchController.searchBar.returnKeyType = .search

        
        // 의존성 주입
        let homeVC = HomeViewController(reactor: homereactor, searchController: searchController)
        
        let navigationController = UINavigationController(rootViewController: homeVC)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

