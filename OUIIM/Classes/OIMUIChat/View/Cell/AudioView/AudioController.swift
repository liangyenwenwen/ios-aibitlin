import Foundation
import AVFAudio
import OUICore

class AudioController: NSObject {
        
    weak var view: AudioView? {
        didSet {
            view?.reloadData()
        }
    }
        
    var onTap: (() -> Void)?
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    var state: AudioViewState = .loading
    
    var duration: Int = 0
    
    private var audioPlayer: AVAudioPlayer?
    
    private var canPlay: Bool = false
    
    private var messageId: String!
    
    private var source: MediaMessageSource!
    
    private var bubbleController: BubbleController!
    
    var messageType: MessageType!
    
    init(source: MediaMessageSource, messageId: String, messageType: MessageType = .incoming, bubbleController: BubbleController) {
        super.init()
        self.source = source
        self.messageId = messageId
        self.bubbleController = bubbleController
        self.duration = source.duration ?? 0
        self.messageType = messageType
    }
    
    deinit {
        AudioPlayController.shared.reset() // 正在播放的时候，返回
    }
    
    func action() {
        guard let url = source.source.url else { return }
        let audioPlayController = AudioPlayController.shared
        
        // 点击的下一条
        if audioPlayController.isPausing(messageID: messageId) || audioPlayController.isPlaying(messageID: messageId) {
            // 如果处于暂停中，就播放
            if audioPlayController.isPausing(messageID: messageId) {
                audioPlayController.play(url: url, messageID: messageId)
                state = .play
                view?.reloadData()
            } else if audioPlayController.isPlaying(messageID: messageId) {
                // 如果点击的是正在播放的语音，就暂停
                audioPlayController.pause(messageID: messageId)
                state = .idle
                view?.reloadData()
            }
            
            return
        }
        // 先停止上一条的播放
        audioPlayController.stop()
        // 开始缓存
        audioPlayController.focus(messageID: messageId)
        
        if url.isFileURL {
            audioPlayController.play(url: url, messageID: messageId)
            state = .play
            view?.reloadData()
        } else {
            let localURL = FileHelper.shared.exsit(path: url.absoluteString)
            // 如果沙盒不存在，就下载
            if localURL == nil {
                FileDownloadManager.manager.downloadMessageFile(messageID: messageId, url: url) { [weak self] msgID, location in
                    // 保存
                    let r = URL(fileURLWithPath: FileHelper.shared.saveAudio(from: location.path, name: location.lastPathComponent).fullPath)
                    // 播放 - 确认缓冲好以后没有切换 audio message
                    if audioPlayController.isFocus(messageID: msgID) {
                        DispatchQueue.main.async {
                            audioPlayController.play(url: r, messageID: msgID)
                            self?.state = .play
                            self?.view?.reloadData()
                        }
                    }
                }
            } else {
                let url = URL(fileURLWithPath: localURL!)
                audioPlayController.play(url: url, messageID: messageId)
                state = .play
                view?.reloadData()
            }
        }
        
        audioPlayController.didFinishPlaying = { [weak self] msgID in
            guard self?.messageId == msgID else { return }
            self?.state = .idle
            self?.view?.reloadData()
        }
        
        onTap?()
    }
}
