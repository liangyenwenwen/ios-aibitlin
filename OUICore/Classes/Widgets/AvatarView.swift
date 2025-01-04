
import Foundation
import UIKit
import RxSwift
import Kingfisher

public class AvatarView: UIView {
    
    public var size: CGFloat = StandardUI.avatarWidth {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var isGroup = false
    
    private var disposeBag = DisposeBag()
    
    private let indexAvatarList = [
        "ic_avatar_01",
        "ic_avatar_02",
        "ic_avatar_03",
        "ic_avatar_04",
        "ic_avatar_05",
        "ic_avatar_06",
        "friend_list_new_friend_icon",
      ]
    
    public let avatarImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.isUserInteractionEnabled = true
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .c0089FF
        
        return v
    }()
    
    public let groupAvatarImageView: UIImageView = {
       let v = UIImageView()
       v.contentMode = .scaleAspectFill
       v.isUserInteractionEnabled = true
       v.translatesAutoresizingMaskIntoConstraints = false
       v.backgroundColor = .c0089FF
        v.isHidden = true
       return v
   }()
    
    private let editAvatarImageView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "pencil.circle"))
        v.tintColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        
        return v
    }()
    
    private let textLabel: UILabel = {
        let v = UILabel()
        v.textAlignment = .center
        v.textColor = .white
        v.font = .f12
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = "loading".innerLocalized()

        return v
    }()
    
    private var onTap: (() -> Void)?
    private var onLongPress: (() -> Void)?
    private var heightConstraint: NSLayoutConstraint!
    private var widthConstraint: NSLayoutConstraint!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 6
        clipsToBounds = true
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        avatarImageView.addSubview(editAvatarImageView)
        addSubview(avatarImageView)
        addSubview(groupAvatarImageView)
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            groupAvatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            groupAvatarImageView.topAnchor.constraint(equalTo: topAnchor),
            groupAvatarImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            groupAvatarImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            editAvatarImageView.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            editAvatarImageView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            editAvatarImageView.widthAnchor.constraint(equalToConstant: 12),
            editAvatarImageView.heightAnchor.constraint(equalToConstant: 12),
            
            textLabel.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
        
        widthConstraint = widthAnchor.constraint(equalToConstant: StandardUI.avatarWidth)
        widthConstraint.priority = UILayoutPriority(999)
        widthConstraint.isActive = true
        heightConstraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
        heightConstraint.priority = UILayoutPriority(999)
        heightConstraint.isActive = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if size != widthConstraint.constant {
            widthConstraint.isActive = false
            
            widthConstraint = widthAnchor.constraint(equalToConstant: size)
            widthConstraint.priority = UILayoutPriority(999)
            widthConstraint.isActive = true
        }
        
        if size != heightConstraint.constant {
            heightConstraint.isActive = false
            
            heightConstraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
            heightConstraint.priority = UILayoutPriority(999)
            heightConstraint.isActive = true
        }
    }
    
    public func setAvatar(url: String?, text: String? = nil, fullText: Bool = false, placeHolder: String = "contact_my_friend_icon", showEdit: Bool = false, isLocal: Bool = false, onTap: (()-> Void)? = nil, onLongPress: (()-> Void)? = nil) {
        
        reset()
        self.onTap = onTap
        self.onLongPress = onLongPress
        
        if let url = url, !url.isEmpty {
            
            if indexAvatarList.contains(url) {// 默认的图
                avatarImageView.isHidden = false
                if isLocal {
                    avatarImageView.image = .init(named: url)
                } else {
                    avatarImageView.image = .init(nameInBundle: url)
                }
                
            } else {
                // 网络图
                    var temp = url.removingPercentEncoding
                    temp = temp?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    avatarImageView.setImage(with: temp, placeHolder: placeHolder, original: false)
                    avatarImageView.backgroundColor = .clear
            }
            avatarImageView.backgroundColor = .clear
        } else if var t = text {
            avatarImageView.image = .image(with: .c0089FF)
            if t.count > 2, !fullText {
                t = String(t.suffix(2))
            }
            textLabel.text = t
        } else {
            avatarImageView.isHidden = false
            if placeHolder == "friend_list_new_friend_icon" {
                avatarImageView.image = .init(named: placeHolder)
            } else {
                avatarImageView.image = .init(nameInBundle: placeHolder)
            }
            
            avatarImageView.backgroundColor = .clear
        }
        
        editAvatarImageView.isHidden = !showEdit
        
        if onTap != nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            avatarImageView.addGestureRecognizer(tap)
            
            let tap2 = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            // animatedImageView.addGestureRecognizer(tap2)
        }

        if onLongPress != nil {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPress.minimumPressDuration = 0.3
            avatarImageView.addGestureRecognizer(longPress)
            
            let longPress2 = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPress2.minimumPressDuration = 0.3
            // animatedImageView.addGestureRecognizer(longPress2)
        }
    }
    
    // MARK: -    设置聊天主页头像
    public func setGroupInfoImg(item: GroupInfo) {
        
        
        IMController.shared.getGroupMemberList(groupId: item.groupID, filter: .all, offset: 0, count: 4) { [self] ms in
                
            var faceUrlArr:[String] = []
            for item in ms {
                faceUrlArr.append(item.faceURL!)
            }
            
            if faceUrlArr.count > 0 {
                
                setGroupImgWithFaceURls(faceUrlArr: faceUrlArr, groupID: item.groupID)
                groupAvatarImageView.backgroundColor = .cE8EAEF
                
            } else {
                
                setAvatar(url: "friend_list_new_friend_icon", text: "", placeHolder: "", isLocal: true)
               
            }
            
        }
    }
    
    public func setGroupImg(item: ConversationInfo) {
        
        
        IMController.shared.getGroupMemberList(groupId: item.groupID!, filter: .all, offset: 0, count: 4) { [self] ms in
                
            var faceUrlArr:[String] = []
            for item in ms {
                faceUrlArr.append(item.faceURL!)
            }
            
            if faceUrlArr.count > 0 {
                
                setGroupImgWithFaceURls(faceUrlArr: faceUrlArr, groupID: item.groupID!)
                groupAvatarImageView.backgroundColor = .cE8EAEF
            } else {
                
                setAvatar(url: "", placeHolder: "friend_list_new_friend_icon", isLocal: true)
               
            }
            
        }
    }
    
    public func setAboutGroupImg(linkurl: String, userId: String) {
        
        setGroupImgWithFaceURls(faceUrlArr: [linkurl], groupID: userId)
        
    }

    
    public func setGroupImg(groupID: String) {
        
        
        IMController.shared.getGroupMemberList(groupId: groupID, filter: .all, offset: 0, count: 4) { [self] ms in
                
            var faceUrlArr:[String] = []
            for item in ms {
                faceUrlArr.append(item.faceURL!)
            }
            
            if faceUrlArr.count > 0 {
                
                setGroupImgWithFaceURls(faceUrlArr: faceUrlArr, groupID: groupID)
                avatarImageView.backgroundColor = .cE8EAEF
            } else {
                
                setAvatar(url: "friend_list_new_friend_icon", text: "", placeHolder: "", isLocal: true)
               
            }
            
        }
    }
    
    
    func setGroupImgWithFaceURls(faceUrlArr: [String], groupID: String) {
        self.isGroup = true
        reset()
        AvatarManager.placeholderImage = UIImage(named: "DefaultAvatar")!
        AvatarManager.groupAvatarType = .QQ
        AvatarManager.distanceBetweenAvatar = 1
        groupAvatarImageView.setImageAvatar(groupId: groupID, groupSource: faceUrlArr)
        
        
    }
    
    
    
    
    
    
    @objc private func handleTap() {
        onTap?()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            onLongPress?()
        }
    }
    
    public func loadGif(url: String) {
        reset()
        avatarImageView.loadGif(url: url, expectSize: 50 * 1024)
    }
    
    public func reset() {
        
        if isGroup {
            avatarImageView.isHidden = true
            groupAvatarImageView.isHidden = false
        } else {
            avatarImageView.isHidden = false
            groupAvatarImageView.isHidden = true
        }
        
        groupAvatarImageView.kf.cancelDownloadTask()
        groupAvatarImageView.contentMode = .scaleAspectFill
        groupAvatarImageView.image = nil
        groupAvatarImageView.backgroundColor = .c0089FF
        
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.image = nil
        avatarImageView.backgroundColor = .c0089FF
        
        textLabel.text = nil
    }
    
    
}
