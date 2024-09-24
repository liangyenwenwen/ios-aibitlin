
import Foundation
import Kingfisher

final class OANoticeViewController {

    weak var view: OANoticeView? {
        didSet {
            view?.reloadData()
        }
    }

    weak var delegate: ReloadDelegate?
        
    let source: NoticeMessageSource
    
    private let messageID: String
    private let bubbleController: BubbleController

    init(messageID: String, source: NoticeMessageSource, bubbleController: BubbleController) {
        self.messageID = messageID
        self.source = source
        self.bubbleController = bubbleController
    }
    
    func action() {
        delegate?.didTapContent(with: messageID, data: .notice(source))
    }
}
