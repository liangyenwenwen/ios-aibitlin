
import Foundation

protocol ReloadDelegate: AnyObject {

    func reloadMessage(with id: String)
    func didTapContent(with id: String,  data: Message.Data)
    func didTapRead(messageID: String)
    func resendMessage(messageID: String)
    func removeMessage(messageID: String)
    func clickPublicCustomerMessage(with id: String, type:String, data: Message.Data)

}

// view 的点击代理，经过controler 传递到 view controller
extension ReloadDelegate {
    func didTapContent(with _: String, _: Message.Data) {}
    func didTapRead(_: String) {}
    func resendMessage(_: String) {}
    func removeMessage(_: String) {}
}

protocol GestureDelegate: AnyObject {
    func longPress(with indexPath: IndexPath, sourceView: UIView, point: CGPoint)
    func onTap(with indexPath: IndexPath)
    func onTapEdgeAligningView()

    func didTapAvatar(with user: User)
    func didLongPressAvatar(with id: String, name: String)

}

extension GestureDelegate {
    func longPress(with _: String, _: UIView, _: CGPoint) {}
    func onTap(with _: IndexPath) {}
    func onTapEdgeAligningView() {}

    func didTapAvatar(with _: User) {}
    func didLongPressAvatar(with _: String, _: String) {}
}
