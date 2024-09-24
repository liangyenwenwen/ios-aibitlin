import OUICore

class Comment: Codable {
    var commentID: String
    var userID: String
    var nickname: String?
    var content: String
    
    var faceURL: String?
    var replyUserID: String?
    var replyNickname: String?
    var replyFaceURL: String?
    var createTime: Int = 0
    
    var isSelf: Bool? {
        return userID == IMController.shared.uid
    }
    private var cacheCommentTextHeight: CGFloat?
}

extension Comment: Equatable {
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return (lhs.commentID == rhs.commentID) && (lhs.userID == rhs.userID)
    }
}

extension Comment {
    var commentAttributedText: NSAttributedString {
        
        let s = NSMutableAttributedString(string: nickname!,
                                          attributes: [NSAttributedString.Key.link: ":sender"])
        
        if replyNickname?.isEmpty == false {
            s.append(NSAttributedString(string: " " + "回复".innerLocalized() + " "))
            s.append(NSAttributedString(string: replyNickname!,
                                        attributes: [NSAttributedString.Key.link: ":other"]))
        }
        
        s.append(NSAttributedString(string: "：" + content))
        
        
        return s
    }
    
    func getCommentHeight(_ baseWidth: CGFloat) -> CGFloat {
        
        var text = commentAttributedText
        
        if cacheCommentTextHeight == nil, text.string.isEmpty == false {
            cacheCommentTextHeight = text.boundingRect(with: CGSize(width: baseWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil).height
        }
        
        return cacheCommentTextHeight ?? 0.0
    }
    
    // 缓存的评论高度
    var commentHeight: CGFloat {
        return cacheCommentTextHeight ?? 0.0
    }
}
