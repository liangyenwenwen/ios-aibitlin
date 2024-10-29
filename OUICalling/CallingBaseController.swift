import UIKit
import Localize_Swift
import Kingfisher

public enum CallingActionType {
    case participantDidDisconnect(_ userID: String, _ duration: Int?)
    case participantDidConnect(_ userID: String)
}

public class CallingBaseController: UIViewController {
    
    public var onAction:((_ action: CallingActionType) -> Void)?
    
    /**
     接收按钮
     */
    @objc public var onAccepted: (() -> Void)?
    /**
     拒绝按钮
     */
    @objc public var onRejected: (() -> Void)?
    /**
     取消按钮
     */
    @objc public var onCancel: (() -> Void)?
    /**
     挂断按钮
     */
    @objc public var onHungup: ((_ duration: Int) -> Void)?
    /**
     邀请按钮
     */
    @objc public var onInvitedOthers: (() -> Void)?
    /**
     链接失败
     */
    @objc public var onConnectFailure: (() -> Void)?
    /**
     断开链接
     */
    @objc public var onDisconnect: (() -> Void)?
    
    /**
     @param isVideo 是否是音视频
     @param inviter 邀请者
     @param others 其它人
     */
    @objc public func startLiveChat(inviter: @escaping UserInfoHandler,
                                    others: @escaping UserInfoHandler,
                                    isVideo: Bool = true,
                                    groupID: String?) {}
    
    /**
     链接房间
     */
    @objc public func connectRoom(liveURL: String, token: String) {}
    /**
     挂断、拒绝等关闭界面
     */
    @objc public func dismiss() {}
    
    public func isConnected() -> Bool { false }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 发送名为"myNotification"的通知
        NotificationCenter.default.post(name: Notification.Name("refrehCallLogs"), object: nil)
    }
}

// 空隙站位
class SizeBox: UIView {
    init(width: Int = 0, height: Int = 0) {
        super.init(frame: .zero)
        
        snp.makeConstraints { make in
            if width > 0 {
                make.width.equalTo(width)
            }
            
            if height > 0 {
                make.height.equalTo(height)
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Bundle {
    static func callingBundle() -> Bundle {
        guard let path = Bundle(for: CallingBaseViewController.self).resourcePath else { return Bundle.main }
        var finalPath: String = path
        finalPath.append("/OIMUICalling.bundle")
        let bundle = Bundle(path: finalPath)
        return bundle ?? Bundle.main
    }
}

extension UIImage {
    convenience init?(nameInBundle: String) {
        self.init(named: nameInBundle, in: Bundle.callingBundle(), compatibleWith: nil)
    }
}

extension UIImageView {
    func setImage(with string: String?, placeHolder: String?) {
        guard let string = string, !string.isEmpty, let url = URL(string: string) else {
            if let placeHolder = placeHolder {
                image = UIImage(named: placeHolder, in: Bundle.callingBundle(), compatibleWith: nil)
            } else {
                image = nil
            }
            return
        }
        let placeImage: UIImage?
        if let placeHolder = placeHolder {
            placeImage = UIImage(named: placeHolder, in: Bundle.callingBundle(), compatibleWith: nil)
        } else {
            placeImage = nil
        }
        kf.setImage(with: url, placeholder: placeImage)
    }
    
    func setImagePath(_ path: String, placeHolder _: String?) {
        if !FileManager.default.fileExists(atPath: path) {
            return
        }
        let url = URL(fileURLWithPath: path)
        image = UIImage(contentsOfFile: url.path)
    }
}

extension String {
    func localized() -> String {
        let bundle = Bundle.callingBundle()
        let str = localized(using: nil, in: bundle)
        
        return str
    }
}
