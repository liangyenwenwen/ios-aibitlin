import Foundation
import UIKit

final class ImageController {

    weak var view: ImageView? {
        didSet {
            view?.reloadData()
        }
    }

    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    var size: CGSize = CGSize(width: 120, height: 120)

    var image: UIImage?

    let messageId: String

    var source: MediaMessageSource

    private let bubbleController: BubbleController

    init(source: MediaMessageSource, messageId: String, bubbleController: BubbleController) {
        self.source = source
        self.messageId = messageId
        self.bubbleController = bubbleController
        
        if let size = source.thumb?.size {
            self.size = size
        }
        
        loadImage()
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
        delegate?.didTapContent(with: messageId, data: .image(source, isLocallyStored: true))
    }
}
