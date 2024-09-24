
import Foundation

protocol EditingBottomControllerDelegate: AnyObject {

    func deleteMessage()
    func forwardMessage(merge: Bool)
}

final class EditingBottomController {
    
    weak var delegate: EditingBottomControllerDelegate?

    weak var view: EditingBottomView?

    func deleteAction() {
        delegate?.deleteMessage()
    }
    
    func forwardAction() {
        delegate?.forwardMessage(merge: true)
    }
}

