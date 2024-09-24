import AVFoundation
import OUICore
import AudioToolbox

class SleepPreventer {
    var audioPlayer: AVAudioPlayer!
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier!
    
    static let preventer = SleepPreventer()
    
    init() {
        setupAudioSession()
        setupAudioPlayer()
    }
    
    func setupAudioSession() {
        // 新建AudioSession会话
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // 设置后台播放
            try audioSession.setActive(false)
            try audioSession.setCategory(.playback, options: .mixWithOthers)
            try audioSession.setActive(true)
        } catch (let e) {
            print("e:\(e)")
        }
    }
    
    func setupAudioPlayer() {
        //静音文件
        let bundle = ViewControllerFactory.getBundle()
        let path = bundle!.path(forResource: "Silence", ofType: "wav")
        do {
            let url = URL(fileURLWithPath: path!)
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer.volume = 0
            audioPlayer.numberOfLoops = 1
            audioPlayer.prepareToPlay()
        } catch (let e) {
            print("e\(e)")
        }
    }
    
    func start() {
        audioPlayer.play()
        applyforBackgroundTask()
    }
    
    func stop() {
        audioPlayer.stop()
    }
    
    //申请后台任务
    func applyforBackgroundTask() {
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            guard let self else { return }
            if self.backgroundTaskIdentifier != .invalid {
                UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
                self.backgroundTaskIdentifier = .invalid
            }
            
            self.start()
        })
    }
}
