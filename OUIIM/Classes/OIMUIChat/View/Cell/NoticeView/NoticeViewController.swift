
import Foundation

final class NoticeViewController {

    weak var view: NoticeView? {
        didSet {
            view?.reloadData()
        }
    }
    
    weak var delegate: ReloadDelegate?

    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    let text: String?

    private let bubbleController: BubbleController

    init(text: String? = nil, bubbleController: BubbleController) {
        self.text = text
        self.bubbleController = bubbleController
    }
    
    func action() {
        delegate?.didTapContent(with: "", data: .notice(NoticeMessageSource(type: .other)))
    }
}
