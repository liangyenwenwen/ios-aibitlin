
import Foundation

final class CustomViewController {

    let text: String?
    
    var attributedString: NSAttributedString?
    
    let type: MessageType
    
    let highlight: Bool
    
    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    private let messageID: String
    
    private let source: CustomMessageSource

    private let bubbleController: BubbleController
    
    var messageType: MessageType!

    init(source: CustomMessageSource, messageID: String, highlight: Bool = false, type: MessageType, bubbleController: BubbleController, messageType: MessageType) {
        self.messageID = messageID
        self.attributedString = source.attributedString
        self.highlight = highlight
        self.type = type
        self.source = source
        self.bubbleController = bubbleController
        self.text = nil
    }
    
    func action() {
        delegate?.didTapContent(with: messageID, data: .custom(source))
    }
}
