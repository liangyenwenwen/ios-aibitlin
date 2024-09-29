
import Foundation

final class CardController {
    var faceURL: String?
    
    var name: String?
    
    var userID: String?

    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    private let source: CardMessageSource

    private let messageId: String
    
    private let bubbleController: BubbleController
    
    weak var view: CardView? {
        didSet {
            view?.reloadData()
        }
    }

    init(source: CardMessageSource, messageID: String, bubbleController: BubbleController) {
        self.source = source
        self.messageId = messageID
        self.bubbleController = bubbleController
        configData()
    }
    
    private func configData() {
        self.name = source.user.name
        self.faceURL = source.user.faceURL
        self.userID = source.user.id
    }
    
    func action() {
        delegate?.didTapContent(with: messageId, data: .card(source))
    }
}
