//
//  AudioManager.swift
//  Challenge
//
//  Created by 김주희 on 3/18/26.
//

import AVFoundation

final class AudioManager {
    
    static let shared = AudioManager()
    
    private init() {}

    private var player: AVPlayer?
    
    func play(url: URL) {
        player?.pause() // 일단 재생되던 노래는 꺼야 안겹침
        
        player = AVPlayer(url: url)
        player?.play()
    }
    
    func play() {
        player?.play()
    }
}
