import Foundation

final class MergeController {

    var title: String?
    
    var abstracts: [String]?
    
    weak var view: MergeView? {
        didSet {
            view?.reloadData()
        }
    }

    private let messageId: String
    
    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    private let source: MergeMessageSource

    private let bubbleController: BubbleController

    init(source: MergeMessageSource, messageID: String, bubbleController: BubbleController) {
        self.messageId = messageID
        self.source = source
        self.bubbleController = bubbleController
        configData()
    }
    
    func configData() {
        title = source.title
        abstracts = source.abstractList
    }
    
    func action() {
        delegate?.didTapContent(with: messageId, data: .merge(source))
    }
}
