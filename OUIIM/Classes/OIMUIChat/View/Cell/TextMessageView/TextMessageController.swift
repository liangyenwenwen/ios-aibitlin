
import Foundation

final class TextMessageController {
    
    weak var view: TextMessageView? {
        didSet {
            view?.reloadData()
        }
    }
    
    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?
    
    let messageID: String
    
    let userID: String

    let text: String?
    
    let attributedString: NSAttributedString?

    let type: MessageType
    
    var highlight: Bool = false
    
    var messageEx: String?

    private let bubbleController: BubbleController

    init(messageID: String, text: String? = nil, attributedString: NSAttributedString? = nil, highlight: Bool = false, type: MessageType, bubbleController: BubbleController,  userID: String  = "", messageEx: String? = nil) {
        self.messageID = messageID
        self.text = text
        self.attributedString = attributedString
        self.highlight = highlight
        self.type = type
        self.bubbleController = bubbleController
        self.userID = userID
        self.messageEx = messageEx
    }
    
    func action(url: URL) {
        delegate?.didTapContent(with: "", data: .url(url, isLocallyStored: false))
    }
}
