
import Foundation

protocol EditingBottomControllerDelegate: AnyObject {

    func deleteMessage()
    func forwardMessage(merge: Bool)
    func canceleChoose()
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
    
    func cancleAction() {
        delegate?.canceleChoose()
    }
}

