
import Foundation

final class LocationController {
        
    var mapURL: String?
    
    var address: String?
    
    var name: String?

    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    private let source: LocationMessageSource

    private let messageId: String
    
    private let bubbleController: BubbleController
    
    weak var view: LocationView? {
        didSet {
            view?.reloadData()
        }
    }

    init(source: LocationMessageSource, messageID: String, bubbleController: BubbleController) {
        self.source = source
        self.messageId = messageID
        self.bubbleController = bubbleController
        configData()
    }
    
    private func configData() {
        mapURL = source.url?.absoluteString
        address = source.address
        name = source.name
    }
    
    func action() {
        delegate?.didTapContent(with: messageId, data: .location(source))
    }
}
