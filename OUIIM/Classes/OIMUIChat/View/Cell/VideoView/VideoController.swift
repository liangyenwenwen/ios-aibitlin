import Foundation
import UIKit
import Kingfisher

final class VideoController {
    
    weak var view: VideoView? {
        didSet {
            view?.reloadData()
        }
    }
    
    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?
    
    var size: CGSize = CGSize(width: 120, height: 120)
    
    var image: UIImage?
    
    let messageId: String
    
    var duration: String?
    
    let source: MediaMessageSource
    
    private let bubbleController: BubbleController
    
    var messageType: MessageType!
    
    init(source: MediaMessageSource, messageId: String, bubbleController: BubbleController, messageType: MessageType) {
        self.source = source
        self.messageId = messageId
        self.bubbleController = bubbleController
        self.duration = formatTime(seconds: TimeInterval(source.duration ?? 0))
        self.messageType = messageType
        if let size = source.thumb?.size {
            self.size = size
        }
        
        loadImage()
    }
    
    private func formatTime(seconds: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        
        if let formattedString = formatter.string(from: seconds) {
            return formattedString
        } else {
            return "00:00:00"
        }
    }
    
    private func loadImage() {
        if let image = source.image {
            self.image = image
            view?.reloadData()
        }else{
            view?.imageView.image = UIImage(nameInBundle: "common_image_placeholder")
        }
    }
    
    func action() {
        delegate?.didTapContent(with: messageId, data: .video(source, isLocallyStored: true))
    }
}
