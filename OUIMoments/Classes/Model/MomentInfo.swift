

import OUICore
import IGListDiffKit

public class MomentsInfo: Decodable {

    // 朋友圈的
    var workMomentID: String = ""
    var content: Content?
    var contentID: String?
    var nickname: String = ""
    var faceURL: String?
    var createTime: Int = 0
    var userID: String = ""
    var likeUsers: [User] = []
    var atUsers: [User] = []
    var permissionUsers: [User] = []
    // 0: 普通 1: 私有 2: 部分 3: 不可见
    var permission: Int = 0
    // 评论数据
    var comments: [Comment] = []
    
    
    // 图片组
    var limage: String?
    // 列表头的背景图
    var backgroundURL: String?
    // 定位
    var location: String?
    var avatar: String?
    
    private var cacheLikeUsersHeight: CGFloat? = 0.0
    // 文字是否展开
    var isTextExpend: Bool? = false
}

extension MomentsInfo {
    
    // 是否是自己发布的
    var isMine: Bool {
        return userID == IMController.shared.uid
    }
    
    // 点赞是否包含自己
    var likesContainsSelf: Bool? {
        return likeUsers.contains(where: { $0.userID == IMController.shared.uid})
    }
}

class Content: Decodable {
    var type: Int = 0 // 0 图文 1 视频
    var metas: [MetaInfo] = []
    var text: String?
    
    init(type: Int, metas: [MetaInfo], text: String?) {
        self.type = type
        self.metas = metas
        self.text = text
    }
}

class MetaInfo: Decodable {
    private var _thumb: String?
    var original: String
    
    var thumb: String {
        set {
            _thumb = newValue
        }
        
        get {
            return _thumb?.isEmpty == false ? _thumb! : original.defaultThumbnailURLString
        }
    }
    
    init(thumb: String? = nil, original: String) {
        self._thumb = thumb
        self.original = original
    }
}

class HeaderInfo {
    var userID: String
    var userName: String
    var faceURL: String?
    var backgroundURL: String?
    var newMsgCount: Int = 0
    
    init(userID: String, userName: String, faceURL: String? = nil, backgroundURL: String? = nil) {
        self.userID = userID
        self.userName = userName
        self.faceURL = faceURL
        self.backgroundURL = backgroundURL
    }
}

extension MomentsInfo {
    /// 图片数组
    var images: [MetaInfo] {
        return content?.metas ?? []
    }
    
    var cellHeight: CGFloat {
        var cellHeight: CGFloat = MomentAvatarSize + MomentWidgetSpace
        
        if content?.text != nil {
            cellHeight += MomentWidgetSpace
            let expandButtonHeight = isNeedExpend ? 30.0 : 0.0
            cellHeight += textHeight + expandButtonHeight
            cellHeight += MomentWidgetSpace
        }

        if !images.isEmpty {
            cellHeight += momentPicsHeight(images.count)
        }

        return cellHeight
    }
    
    var operateHeight: CGFloat {
        // 提到谁的label展示
        return atUsers.isEmpty ? 28 : 50
    }
    
    /// 文字是否需要展开
    var isNeedExpend: Bool {
        guard let text = content?.text else { return false}
        let lines = text.textLines(MomentContentWidth, font: UIFont.f17)
        
        return lines.count > 3
    }
    
    var textHeight: CGFloat {
        guard let text = content?.text else { return 0 }
        let lines = text.textLines(MomentContentWidth, font: UIFont.f17)

        return UIFont.f17.lineHeight * CGFloat((lines.count > 3 && !(isTextExpend ?? false) ? 3 : lines.count))
    }
    
    func momentPicsHeight(_ picCount: Int) -> CGFloat {
        let itemsPerRow = 3
        let imageWidth = MomentContentWidth / CGFloat(itemsPerRow)

        if picCount == 1 {
            return (imageWidth * 16 / 9.0)
        } else {
            let rows = (picCount + itemsPerRow - 1) / itemsPerRow
            return CGFloat(rows) * imageWidth
        }
    }
    
    // 点赞的列表
    var likeUsersAttributedText: NSAttributedString? {
        
        var likeUsersText: NSAttributedString?
        
        if !likeUsers.isEmpty {

            let result = NSMutableAttributedString()
            let displayUsers = likeUsers.count > 10 ? Array(likeUsers[0...9]) : likeUsers

            for i in 0..<displayUsers.count {

                let u = displayUsers[i]
                var uName = SuperStringUtil.getUserState(showname: u.nickname).n
                // 如果是最后一个
                if i < displayUsers.count - 1 {
                    uName += "、"
                }

                result.append(NSAttributedString(string: uName,
                                                 attributes: [NSAttributedString.Key.link: "likeUser:\(u.userID)",
                                                              NSAttributedString.Key.foregroundColor : UIColor(hex: 0x6085b1),
                                                              NSAttributedString.Key.underlineColor : UIColor.clear]))
            }

            if (likeUsers.count) > 10 {
                result.append(NSAttributedString(string: "等\(likeUsers.count)人点赞"))
            }

            likeUsersText = result
        }
        
        return likeUsersText
    }
    
    // 计算点赞的高度
    private func getLikeUsersHeight(_ baseWidth: CGFloat) -> CGFloat {
        
        if likeUsers.isEmpty {
            return 0.0
        }
        
        var text = likeUsersAttributedText
        
        if cacheLikeUsersHeight == nil, text?.string.isEmpty == false {
            cacheLikeUsersHeight = text!.boundingRect(with: CGSize(width: baseWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin] ,context: nil).height
            cacheLikeUsersHeight = ceil(cacheLikeUsersHeight!)
        }
        
        print("点赞的高度 \(content) ：\(cacheLikeUsersHeight), \(likeUsersAttributedText?.string)")
        return text?.string.isEmpty == false ? cacheLikeUsersHeight! + 10 : 0.0 // stackview的spacing 6
    }
    
    var likeUsersHeight: CGFloat {
        return cacheLikeUsersHeight ?? 0.0
    }
    
    // 所有评论的高度
    func getCommentsHeight(_ baseWidth: CGFloat) -> CGFloat {
        
        var height = 0.0
        comments.forEach { info in
            height += info.getCommentHeight(baseWidth)
            height += 4 // 展示内容的textview，上下padding
        }
        if !comments.isEmpty {
            height += 10 // 为tableview加的
        }
        print("评论的高度 \(content)：\(height)")
        return height
    }
    
    // 点赞 + 评论的高度
    func contentHeight(_ baseWidth: CGFloat) -> CGFloat {
        return getCommentsHeight(baseWidth) + getLikeUsersHeight(baseWidth) + 1 // 分割线1
    }
}

extension MomentsInfo: ListDiffable {
    
    public func diffIdentifier() -> NSObjectProtocol {
        return workMomentID as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self === object else { return true }
        guard let object = object as? MomentsInfo else { return false }
        return workMomentID == object.workMomentID
    }
}

extension HeaderInfo: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        return userID as NSObjectProtocol
    }
    
    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self === object else { return true }
        guard let object = object as? HeaderInfo else { return false }
        return userID == object.userID
    }
}
