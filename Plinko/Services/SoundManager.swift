//
//  SoundManager.swift
//  Plinko
//
//  Created by Yaroslav Golinskiy on 15/09/2025.
//

import AVFoundation
import AudioToolbox

// MARK: - Sound Manager
class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            // Якщо файл не знайдено, використовуємо системний звук
            AudioServicesPlaySystemSound(1104) // Звук клацання
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Помилка відтворення звуку: \(error)")
        }
    }
    
    func playPinHit() {
        AudioServicesPlaySystemSound(1104) // Звук зіткнення
    }
    
    func playSlotHit() {
        AudioServicesPlaySystemSound(1105) // Звук попадання
    }
}
