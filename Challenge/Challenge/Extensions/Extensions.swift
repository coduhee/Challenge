//
//  UIImageView+Extension.swift
//  Challenge
//
//  Created by 김주희 on 3/15/26.
//

import UIKit
import Kingfisher


// MARK: - loadImage
extension UIImageView {
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            self.image = nil
            return
        }
        
        self.kf.setImage(
            with: url,
            placeholder: nil,
            options: [
                .transition(.fade(0.2)), // 부드럽게 이미지 페이드 인
                .cacheOriginalImage // 원본 이미지를 캐시에 저장
            ]
        )
    }
}


// MARK: - Alert
extension UIViewController {
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "에러",
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "확인", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
