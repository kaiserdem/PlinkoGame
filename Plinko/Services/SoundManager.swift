
import AVFoundation
import AudioToolbox

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?
    
    private init() {}
    
    func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            AudioServicesPlaySystemSound(1104)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func playPinHit() {
        AudioServicesPlaySystemSound(1104)
    }
    
    func playSlotHit() {
        AudioServicesPlaySystemSound(1105)
    }
}
