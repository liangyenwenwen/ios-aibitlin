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
        
        let s = NSMutableAttributedString(string: SuperStringUtil.getUserState(showname: nickname!).n,
                                          attributes: [NSAttributedString.Key.link: ":sender"])
        
        if replyNickname?.isEmpty == false {
            s.append(NSAttributedString(string: " " + "回复".innerLocalized() + " "))
            s.append(NSAttributedString(string: SuperStringUtil.getUserState(showname: replyNickname!).n,
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



class SuperStringUtil {
    
    static func getWeekDay (dateTime : String ) -> String {
        let dateFmt =  DateFormatter ()
        dateFmt.dateFormat = "yyyy-MM-dd"
        let date = dateFmt.date(from: dateTime )!
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        let weekDays = [NSNull.init(),"周日","周一","周二","周三","周四","周五","周六"]as [Any]
        if let weekday = components.weekday {
            return weekDays[weekday] as! String
        }
        return "error"
    }
    
    static func getUserState(showname: String) -> UserState {
        guard let jsonData = showname.data(using: .utf8) else { return UserState(b: 0, e: 0, v: 0, n: showname)}
        do {
            let user = try JSONDecoder().decode(UserState.self, from: jsonData)
            return user
        } catch {
            return  UserState(b: 0, e: 0, v: 0, n: showname)
        }
    }
    
    static func getUserTag(showname: String) -> String? {
        guard let jsonData = showname.data(using: .utf8) else { return nil}
        do {
            let user = try JSONDecoder().decode(UserState.self, from: jsonData)
            var reslut = ""
            if user.v > 0 {
                reslut.append("V\(user.v)")
            }
            
            if user.b > 0 {
                reslut.append(reslut.count == 0 ? "\("网站".localized())" : "、\("网站".localized())")
            }
            
            if user.e > 0 {
                reslut.append(reslut.count == 0 ? "\("企业".localized())" : "、\("企业".localized())")
            }
            
            return reslut.count == 0 ? nil : "[\(reslut)]"
        } catch {
            return  nil
        }
    }
    
}


struct UserState: Codable {
    let b: Int
    let e: Int
    let v: Int
    let n: String
}
