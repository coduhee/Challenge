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


// MARK: - generate AverageColor
extension UIImage {
    
    // 평균 색상 추출 함수
    func averageColor() -> UIColor? {
        guard let cgImage = cgImage else { return nil }
        
        // 이미지를 아주 작게(1x1) 렌더링해서 전체 평균색을 뽑아내는 고속 방식
        let size = CGSize(width: 1, height: 1)
        let context = CGContext(data: nil,
                                width: 1, height: 1,
                                bitsPerComponent: 8, bytesPerRow: 4,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
        
        guard let data = context?.data else { return nil }
        
        let red = CGFloat(data.load(fromByteOffset: 0, as: UInt8.self)) / 255.0
        let green = CGFloat(data.load(fromByteOffset: 1, as: UInt8.self)) / 255.0
        let blue = CGFloat(data.load(fromByteOffset: 2, as: UInt8.self)) / 255.0
        let alpha = CGFloat(data.load(fromByteOffset: 3, as: UInt8.self)) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // 색상의 진한 정도를 조절하는 함수
        func generateVividBackgroundColor() -> UIColor? {
            guard let avgColor = averageColor() else { return nil }
            
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            avgColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            
            let colorRatio: CGFloat = 0.85 // 1에 가까울수록 진한 색상, 0에 가까울수록 연한 색상
            let whiteRatio: CGFloat = 1.0 - colorRatio
            
            return UIColor(
                red: (r * colorRatio) + whiteRatio,
                green: (g * colorRatio) + whiteRatio,
                blue: (b * colorRatio) + whiteRatio,
                alpha: 1.0
            )
        }
}
