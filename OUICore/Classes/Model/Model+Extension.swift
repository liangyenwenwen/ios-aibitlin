
import Foundation
import UIKit

public enum ContactItemType: Codable {
    case user
    case group
}

public struct ContactInfo: Codable {
    public let ID: String?
    public let name: String?
    public let faceURL: String?
    public let sub: String?
    public var type: ContactItemType
    public var createTime: Int
    
    public init(ID: String? = nil, name: String? = nil, faceURL: String? = nil, sub: String? = nil, type: ContactItemType = .user, createTime: Int = 0) {
        self.ID = ID
//        self.name = name
        self.name = SuperStringUtil.getUserShowname(showname: name ?? "")
        self.faceURL = faceURL
        self.sub = sub
        self.type = type
        self.createTime = createTime
    }
}

extension ContactInfo {
    public func toSimpleFullUserInfo() -> PublicUserInfo {
        PublicUserInfo(userID: ID!, nickname: name, faceURL: faceURL)
    }
}

fileprivate let nameAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font: UIFont.f14,
    NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
    NSAttributedString.Key.underlineStyle: 0
]

fileprivate let contentAttributes: [NSAttributedString.Key: Any] = [
    NSAttributedString.Key.font: UIFont.f14,
    NSAttributedString.Key.foregroundColor: UIColor.c8E9AB0,
    NSAttributedString.Key.underlineStyle: 0
]

fileprivate func actionNameAttributes(userID: String) -> [NSAttributedString.Key: Any] {
    [   NSAttributedString.Key.link: "\(linkSchme)\(userID)",
        NSAttributedString.Key.font: UIFont.f14,
        NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
        NSAttributedString.Key.underlineStyle: 0
    ]
}

fileprivate func actionReEditAttributes(messageID: String) -> [NSAttributedString.Key: Any] {
    [   NSAttributedString.Key.link: "\(reEditSchme)\(messageID)",
        NSAttributedString.Key.font: UIFont.f14,
        NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
        NSAttributedString.Key.underlineStyle: 0
    ]
}

fileprivate let actionSendFriendReqestAttributes: [NSAttributedString.Key: Any] =
    [   NSAttributedString.Key.link: "\(sendFriendReqSchme)",
        NSAttributedString.Key.font: UIFont.f14,
        NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
        NSAttributedString.Key.underlineStyle: 0
    ]

public let linkSchme = "link://"
public let reEditSchme = "reEdit://"
public let sendFriendReqSchme = "sendFriendReq://"

extension MessageInfo {
    public func getAbstruct() -> String? {
        switch contentType {
        case .text:
            return content
        case .quote:
            return quoteElem?.text
        case .at:
            return atTextElem?.atText
        default:
            return contentType.abstruct
        }
    }
}


extension MessageContentType {
    public var abstruct: String {
        switch self {
        case .image:
            return "[\("图片".innerLocalized())]"
        case .audio:
            return "[\("语音".innerLocalized())]"
        case .video:
            return "[\("视频".innerLocalized())]"
        case .file:
            return "[\("文件".innerLocalized())]"
        case .card:
            return "[\("名片".innerLocalized())]"
        case .location:
            return "[\("定位".innerLocalized())]"
        case .merge:
            return "[\("mergeForward".innerLocalized())]"
        case .face:
            return "[自定义表情]"
        case .custom:
            return "[自定义模版]"
        default:
            return ""
        }
    }
}

extension GroupMemberInfo {
    public var isSelf: Bool {
        return userID == IMController.shared.uid
    }
    
    public var joinWay: String {
        switch joinSource {
        case .invited:
            return "\(inviterUserName ?? "")\("邀请加入".innerLocalized())"
        case .search:
            return "搜索加入".innerLocalized()
        case .QRCode:
            return "扫描二维码加入".innerLocalized()
        }
    }
    
    public var roleLevelString: String {
        switch roleLevel {
        case .admin:
            return "管理员".innerLocalized()
        case .owner:
            return "创建者".innerLocalized()
        default:
            return ""
        }
    }
    
    public var isOwnerOrAdmin: Bool {
        return roleLevel == .owner || roleLevel == .admin
    }
}

extension GroupInfo {
    public func needVerificationText() -> String {
        
        if (needVerification == .allNeedVerification) {
            return "needVerification".innerLocalized()
        } else if (needVerification == .directly) {
            return "allowAnyoneJoinGroup".innerLocalized()
        }
        return "inviteNotVerification".innerLocalized()
    }
}

extension UserStatusInfo {
    public var statusDesc: String {
        if status == 0 {
            return "离线".innerLocalized()
        }
        let des = platformIDs!.compactMap { platform in
            switch (platform) {
            case 1:
                return "iOS"
            case 2:
                return "Android"
            case 3:
                return "Windows"
            case 4:
                return "Mac"
            case 5:
                return "Web"
            case 6:
                return "mini_web"
            case 7:
                return "Linux"
            case 8:
                return "Android_pad"
            case 9:
                return "iPad"
            default:
                return nil
            }
        }
        return des.joined(separator: "/") + "在线".innerLocalized()
    }
}

extension FaceElem {
    public var url: String? {
        if let data {
            let obj = try! JSONSerialization.jsonObject(with: data.data(using: .utf8)!) as? [String: Any]
            let t = obj?["url"] as? String
            
            return t
        }
        
        return nil
    }
}

extension AtTextElem {
    public var atText: String {
        var temp = text!
        atUserList?.forEach({ userID in
            if let userName = atUsersInfo?.first(where: { $0.atUserID == userID })?.groupNickname {
                temp = temp.replacingOccurrences(of: "@\(userID)",
                                                 with: "@\(userName)")
            }
        })
        
        return temp
    }
    
    private func actionNameAttributes(userID: String) -> [NSAttributedString.Key: Any] {
        [   NSAttributedString.Key.link: "link://\(userID)",
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue,
            NSAttributedString.Key.underlineStyle: 0
        ]
    }
    
    private func replaceUserIDToName(attrString: NSMutableAttributedString, userID: String, to userName: String) -> NSAttributedString {
        let range = (attrString.string as NSString).range(of: "@\(userID)")
        
        if range.location != NSNotFound {
            let rName = "@\(userName)"
                        
            attrString.beginEditing()
            attrString.replaceCharacters(in: range, with: rName)
            let uID = userID == IMController.shared.atAllTag() ? "" : userID
            attrString.addAttributes(actionNameAttributes(userID: uID), range: NSMakeRange(range.location, rName.length))
            attrString.endEditing()

            replaceUserIDToName(attrString: attrString, userID: userID, to: userName)
        }
        
        return attrString
    }
    
    public var atAttributeString: NSAttributedString {
        var attrText = NSAttributedString(string: text!)
        
        if let atUserList, let text, let atUsersInfo {
            attrText = createAttrString(baseString: text, users: atUsersInfo)
        }
        
        return attrText
    }
    
    func createAttrString(baseString inputString: String, users: [AtInfo]) -> NSMutableAttributedString {
        
        var tempText = inputString
        
        for user in users {
            let nickname = user.atUserID == IMController.shared.uid ? "you".innerLocalized() : user.groupNickname ?? user.atUserID!
            
            tempText.replace("@\(user.atUserID!)", withString: "@\(nickname)")
        }
        
        let content = NSMutableAttributedString(string: tempText)
        
        for user in users {
            let nickname = user.atUserID == IMController.shared.uid ? "you".innerLocalized() : user.groupNickname ?? user.atUserID!
            
            var currentIndex = tempText.startIndex
            while currentIndex < tempText.endIndex {
                if let range = tempText[currentIndex...].range(of: "@\(nickname)", options: .literal) {
                    let nsRange = NSRange(range, in: tempText)
                    content.addAttributes(actionNameAttributes(userID: user.atUserID!), range: nsRange)
                    currentIndex = range.upperBound
                } else {
                    currentIndex = tempText.index(after: currentIndex)
                }
            }
        }
        
        return content
    }
}

extension MessageInfo {
    public func getSummary() -> String {
        return MessageHelper.getSummary(by: self)
    }
    
    public func systemNotification(showReEdit: Bool = false, highlight: Bool = true) -> NSAttributedString? {
        
        func createAttrString(baseString inputString: String, users: [GroupMemberInfo]) -> NSMutableAttributedString {
            let content = NSMutableAttributedString(string: inputString, attributes: contentAttributes)
            
            for user in users {
                let nickname = user.isSelf ? "you".innerLocalized() : user.nickname ?? user.userID!
                
                var currentIndex = inputString.startIndex
                while currentIndex < inputString.endIndex {
                    if let range = inputString[currentIndex...].range(of: nickname, options: .literal) {
                        let nsRange = NSRange(range, in: inputString)
                        content.addAttributes(highlight ? actionNameAttributes(userID: user.userID!) : contentAttributes, range: nsRange)
                        currentIndex = range.upperBound
                    } else {
                        currentIndex = inputString.index(after: currentIndex)
                    }
                }
            }
            
            return content
        }
        
        func formatUsersName(users: [GroupMemberInfo]) -> String {
            users.compactMap({ $0.userID == IMController.shared.uid ? "you".innerLocalized() : (SuperStringUtil.getUserShowname(showname: $0.nickname ?? "") ?? $0.userID) }).joined(separator: "、")
        }
        
        func spaceString() -> NSAttributedString {
            return NSAttributedString(string: " ", attributes: contentAttributes)
        }
        
        func opUserName(message: MessageInfo) -> String {
            guard let opUser = message.notificationElem?.opUser else { return "" }
            
            if opUser.userID == IMController.shared.uid {
                return "you".innerLocalized()
            } else {
                return opUser.nickname ?? ""
            }
        }

        var result: NSMutableAttributedString?
        
        switch contentType {
        case .friendAppApproved:
            
            result = NSMutableAttributedString(string: "friendAddedNtf".innerLocalized(), attributes: contentAttributes)
        case .memberQuit:

            if let notificationElem, let user = notificationElem.quitUser {
                
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (user.nickname ?? user.userID!)
                let str = "quitGroupNtf".innerLocalizedFormat(arguments: nickname)
                
                result = createAttrString(baseString: str, users: [user])
            }
        case .memberEnter:
            
            if let notificationElem, let user = notificationElem.entrantUser {
                
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (user.nickname ?? user.userID!)
                let str = "joinGroupNtf".innerLocalizedFormat(arguments: SuperStringUtil.getUserShowname(showname: nickname))
                
                result = createAttrString(baseString: str, users: [user])
            }
        case .memberKicked:
            
            if let notificationElem, let users = notificationElem.kickedUserList, let opUser = notificationElem.opUser {
                let opNickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)

                let nicknames = formatUsersName(users: users)
                let str = "kickedGroupNtf".innerLocalizedFormat(arguments: nicknames, SuperStringUtil.getUserState(showname: opNickname).n)
                
                result = createAttrString(baseString: str, users: users + [opUser])
            }
        case .memberInvited:
            
            if let notificationElem, let users = notificationElem.invitedUserList, let opUser = notificationElem.opUser {
                let opNickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)
                
                let nicknames = formatUsersName(users: users)
                
                let str = "invitedJoinGroupNtf".innerLocalizedFormat(arguments: SuperStringUtil.getUserShowname(showname: opNickname), nicknames)
                
                result = createAttrString(baseString: str, users: users + [opUser])
            }
        case .groupCreated:
            
            if let notificationElem, let opUser = notificationElem.opUser {
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)
                
                let str = "createGroupNtf".innerLocalizedFormat(arguments: SuperStringUtil.getUserShowname(showname: nickname ?? ""))
                result = createAttrString(baseString: str, users: [opUser])
            }
        case .groupInfoSet:
            
            if let notificationElem, let opUser = notificationElem.opUser {
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)
                
                let str = "editGroupInfoNtf".innerLocalizedFormat(arguments: nickname)
                result = createAttrString(baseString: str, users: [opUser])
            }
        case .revoke:
            
            var revoker = ""
            var beRevoker = ""
            
            if revokedInfo.sessionType == .c2c {
                revoker = revokedInfo.revokerIsSelf ? "you".innerLocalized() : revokedInfo.revokerNickname ?? ""
            } else {
                revoker = revokedInfo.revokerIsSelf ? "you".innerLocalized() : revokedInfo.revokerNickname!
                beRevoker = (revokedInfo.revokerIsSelf && revokedInfo.sourceMessageSendIDIsSelf) || 
                revokedInfo.revokerID == revokedInfo.sourceMessageSendID
                ? "" : 
                (revokedInfo.sourceMessageSendIDIsSelf ? "you".innerLocalized() : revokedInfo.sourceMessageSenderNickname!)
            }
                            
            let revokerInfo = GroupMemberInfo()
            revokerInfo.userID = revokedInfo.revokerID
            revokerInfo.nickname = revoker
            
            if !beRevoker.isEmpty {
                let beRevokerInfo = GroupMemberInfo()
                beRevokerInfo.userID = revokedInfo.revokerID
                beRevokerInfo.nickname = beRevoker
                
                let str = "aRevokeBMsg".innerLocalizedFormat(arguments: revoker, beRevoker)
                result = createAttrString(baseString: str, users: [revokerInfo, beRevokerInfo])
            } else {
                let str = "revokeMsg".innerLocalizedFormat(arguments: revoker)
                result = createAttrString(baseString: str, users: [revokerInfo])
            }
            
            if revokedInfo.sourceMessageSendIDIsSelf, revokedInfo.revokerIsSelf, showReEdit {
                result!.append(spaceString())
                let reEdit = NSAttributedString(string: "reEdit".innerLocalized(), attributes: highlight ? actionReEditAttributes(messageID: revokedInfo.clientMsgID!) : contentAttributes)
                
                result!.append(reEdit)
            }
        case .conversationNotification:
            result = NSMutableAttributedString(string: "enabledNoDisturb".innerLocalized(), attributes: contentAttributes)
            
        case .conversationNotNotification:
            result = NSMutableAttributedString(string: "disableNoDisturb".innerLocalized(), attributes: contentAttributes)

        case .dismissGroup:
            
            if let notificationElem, let opUser = notificationElem.opUser {
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)
                
                let str = "dismissGroupNtf".innerLocalizedFormat(arguments: nickname)
                result = createAttrString(baseString: str, users: [opUser])
            }
        case .typing:
            return nil
        case .privateMessage:
            
            if let value = notificationElem?.detailObject {
                let enable = value["isPrivate"] as? Bool
                result = NSMutableAttributedString(string: enable == true ?
                                                 "openPrivateChatNtf".innerLocalized() :
                                                 "closePrivateChatNtf".innerLocalized(),
                                                 attributes: contentAttributes)
            }

        case .groupMuted:
            
            if let notificationElem, let opUser = notificationElem.opUser {
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)
                
                let str = "muteGroupNtf".innerLocalizedFormat(arguments: nickname)
                result = createAttrString(baseString: str, users: [opUser])
            }
        case .groupCancelMuted:
            
            if let notificationElem, let opUser = notificationElem.opUser {
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)
                
                let str = "muteCancelGroupNtf".innerLocalizedFormat(arguments: nickname)
                result = createAttrString(baseString: str, users: [opUser])
            }
        case .groupOwnerTransferred:
            
            if let notificationElem, let opUser = notificationElem.opUser, let newOwner = notificationElem.groupNewOwner {
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)
                let newNickname = newOwner.isSelf ? "you".innerLocalized() : (newOwner.nickname ?? newOwner.userID!)
                
                let str = "transferredGroupNtf".innerLocalizedFormat(arguments: nickname, newNickname)
                result = createAttrString(baseString: str, users: [opUser, newOwner])
            }
        case .groupSetName:
            
            if let notificationElem, let opUser = notificationElem.opUser, let group = notificationElem.group {
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)

                let str = "whoModifyGroupName".innerLocalizedFormat(arguments: nickname, group.groupName ?? "")
                result = createAttrString(baseString: str, users: [opUser])
            }
        case .groupAnnouncement:
            
            if let notificationElem, let notification = notificationElem.group?.notification {
                result = NSMutableAttributedString(string: notification)
            }
        case .oaNotification:
            ///  获取系统通知摘要
            if let detail = notificationElem?.detailObject {
                
                if let detailText = detail["text"]  {
                   
                    if let jsonData = (detailText as! String).data(using: .utf8)  {
                          
                        do {
                            let user = try JSONDecoder().decode(systemCustomNotitifyItem.self, from: jsonData)
//                            result = NSMutableAttributedString(string: user.cont!, attributes: contentAttributes)
                            result = NSMutableAttributedString(string: "\(detail["notificationName"] ?? "")", attributes: contentAttributes)
                        } catch {
                            result = NSMutableAttributedString(string: detailText as! String, attributes: contentAttributes)
                        }
                    } else {
                        result = NSMutableAttributedString(string: "", attributes: contentAttributes)
                    }

                    
                    
                } else {
                    
                    result = NSMutableAttributedString(string: "", attributes: contentAttributes)
                }
                
//                result = NSMutableAttributedString(string: "\(detail["text"] ?? "")", attributes: contentAttributes)
            }
        case .groupMemberMuted:
            
            if let notificationElem,
                let opUser = notificationElem.opUser,
                let detail = notificationElem.detailObject as? [String: Any],
                let mutedUser = detail["mutedUser"] as? [String: Any],
                let mutedSeconds = detail["mutedSeconds"] as? Int {
                
                var dispalySeconds = FormatUtil.getMutedFormat(of: mutedSeconds)
                let muted = GroupMemberInfo()
                muted.userID = mutedUser["userID"] as! String
                muted.nickname = mutedUser["nickname"] as? String
                
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)
                let mutedNickname = muted.isSelf ? "you".innerLocalized() : (muted.nickname ?? muted.userID!)
                
                let str = "muteMemberNtf".innerLocalizedFormat(arguments: mutedNickname, nickname, dispalySeconds)
                result = createAttrString(baseString: str, users: [muted, opUser])
            }
        case .groupMemberCancelMuted:
            
            if let notificationElem,
                let opUser = notificationElem.opUser,
                let detail = notificationElem.detailObject as? [String: Any],
                let mutedUser = detail["mutedUser"] as? [String: Any] {
                
                let muted = GroupMemberInfo()
                muted.userID = mutedUser["userID"] as! String
                muted.nickname = mutedUser["nickname"] as? String
                
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)
                let mutedNickname = muted.isSelf ? "you".innerLocalized() : (muted.nickname ?? muted.userID!)

                let str = "muteCancelMemberNtf".innerLocalizedFormat(arguments: mutedNickname, nickname)
                result = createAttrString(baseString: str, users: [muted, opUser])
            }
        case .groupMemberInfoSet:
            
            if let notificationElem, let opUser = notificationElem.opUser {
                let nickname = notificationElem.opUserIsMe ? "you".innerLocalized() : (opUser.nickname ?? opUser.userID!)

                let str = "editedMemberInfo".innerLocalizedFormat(arguments: nickname)
                result = createAttrString(baseString: str, users: [opUser])
            }
        default:
            result = NSMutableAttributedString(string: "\("unsupportedMessage".innerLocalized()) \(contentType)", attributes: contentAttributes)
        }
        
        return result
    }
    
    public var customMessageAbstruct: String {
        guard let type = customElem?.type else {
            return "不支持的消息类型".innerLocalized()
        }
        
        switch type {
        case .call:
            return "[" + "音视频".innerLocalized() + "]"
        case .customEmoji:
            return "[" + "表情" + "]".innerLocalized()
        case .tagMessage:
            return "[" + "标签" + "]".innerLocalized()
        case .blockedByFriend:
            return "blockedByFriendHint".innerLocalized()
        case .deletedByFriend:
            return "deletedByFriendHint".innerLocalizedFormat(arguments: "sendFriendVerification".innerLocalized())
        case .moments:
            return "[" + "朋友圈".innerLocalized() + "]"
        case .meeting:
            return "[" + "meetingInvitation".innerLocalized() + "]"
        case .boke:
            return "[" + "网站".innerLocalized() + "]"
        case .commonTemplate:
           if let data = customElem?.value() {
               var title = data["title"] as? String
               if let item = data["item"] as? [String: Any],
                  let intro = item["intro"] as? String{
                   if intro.length > 0 {
                       return "[" + (title ?? "") + "-" + intro + "]"
                   }
                   
               }
               return "[" + (title ?? "小程序") + "]"
           }else{
               return "[" + "小程序".innerLocalized() + "]"
           }
        }
    }
    
    public var customMessageDetailAttributedString: NSAttributedString {
        
        guard contentType == .custom,
                let type = customElem?.type,
                let value = customElem?.value() else { return NSAttributedString() }
        
        var str = NSMutableAttributedString()
        
        switch type {
        case .blockedByFriend:
            
            str = NSMutableAttributedString(string: "blockedByFriendHint".innerLocalized(), attributes: contentAttributes)
        case .deletedByFriend:
            let addFirendStr = "sendFriendVerification".innerLocalized()
            let baseStr = "deletedByFriendHint".innerLocalizedFormat(arguments: addFirendStr)
            str = NSMutableAttributedString(string: baseStr, attributes: contentAttributes)
                
            var currentIndex = baseStr.startIndex
            while currentIndex < baseStr.endIndex {
                if let range = baseStr[currentIndex...].range(of: addFirendStr, options: .literal) {
                    let nsRange = NSRange(range, in: baseStr)
                    str.addAttributes(actionSendFriendReqestAttributes, range: nsRange)
                    currentIndex = range.upperBound
                } else {
                    currentIndex = baseStr.index(after: currentIndex)
                }
            }
            
        case .call:
            
            let isVideo = value["type"] as? String == "video"
            
            let imageAttachment = NSTextAttachment()
            
//            if isMine {
//                imageAttachment.image = UIImage(named: !isVideo ? "chat_voice_1" : "chat_video_1")
//                imageAttachment.bounds = CGRect(x: 0, y: -3, width: 18, height: 18)
//            } else {
//                imageAttachment.image = UIImage(named: !isVideo ? "chat_voice_1" : "chat_video_1")
//                imageAttachment.bounds = CGRect(x: 0, y: -3, width: 18, height: 18)
//            }
            if isMine {
                imageAttachment.image = UIImage(named: !isVideo ? "call_log_auido" : "call_log_video")
                imageAttachment.bounds = CGRect(x: 0, y: -3, width: 18, height: 18)
            } else {
                imageAttachment.image = UIImage(named: !isVideo ? "call_log_auido" : "call_log_video")
                imageAttachment.bounds = CGRect(x: 0, y: -3, width: 18, height: 18)
            }
            
            

            str.append(NSAttributedString(attachment: imageAttachment))
            
            if let msg = value["msg"] as? String {
                
//                if isMine {
//                    str.append(NSAttributedString(string: msg, attributes: [.font: UIFont.f17, .foregroundColor: UIColor.white]))
//                } else {
                    str.append(NSAttributedString(string: " " + msg, attributes: [.font: UIFont.f17, .foregroundColor: UIColor.init(hexString: "#333333")]))
//                }
                
            }
            
        case .meeting:
            
            let inviterNickname = value["inviterNickname"] as? String
            let start = Date.timeString(timeInterval: (value["start"] as! TimeInterval) * 1000)
            let duration = value["duration"] as! Int
            let ID = value["id"] as! String
            
            let space = NSAttributedString(string: " \n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 8)])
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(nameInBundle: "chat_live_room_icon")
            imageAttachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)
            str.append(NSAttributedString(attachment: imageAttachment))
            
            let text = " \("meetingInitiatorIs".innerLocalizedFormat(arguments: inviterNickname ?? ""))" +
            "\n • \("meetingStartTimeIs".innerLocalizedFormat(arguments: start))" +
            "\n • \("meetingDurationIs".innerLocalizedFormat(arguments: formatTime(seconds: duration)))" +
            "\n • \("meetingNoIs".innerLocalizedFormat(arguments: ID))"
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            paragraphStyle.lineBreakMode = .byWordWrapping

            str.append(NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                                                       NSAttributedString.Key.font: UIFont.f17]))
            
            let paragraphStyle2 = NSMutableParagraphStyle()
            paragraphStyle2.lineSpacing = 16
            paragraphStyle2.alignment = .center
            
            let tips = NSAttributedString(string: "\n\("enterMeeting".innerLocalized()) ",
                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.c0089FF,
                                                       NSAttributedString.Key.font: UIFont.f17,
                                                       NSAttributedString.Key.paragraphStyle: paragraphStyle2])
            
            str.append(tips)
            
            let arrowAttachment = NSTextAttachment()
            arrowAttachment.image = UIImage(nameInBundle: "common_blue_arrow_right_icon")
            arrowAttachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)
            str.append(NSAttributedString(attachment: arrowAttachment))
            
        default:
            break
        }
        
        return str
    }
    
    private func formatTime(seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full

        if seconds >= 3600 {
            formatter.allowedUnits = [.hour, .minute]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }

        guard let formattedString = formatter.string(from: TimeInterval(seconds)) else {
            return ""
        }

        return formattedString
    }
}

extension ConversationInfo {
    public var summary: String? {
        return conversationType == .c2c ? latestMsg?.getSummary() : showName! + ":" + (latestMsg?.getSummary())!
    }
    
    var prefix: String? {
        
        if let draftText, draftText.length > 0 {
            return "[\("草稿".innerLocalized())]"
        }
        
        guard conversationType == .superGroup else { return nil }
        
        switch groupAtType {
        case .normal:
            return nil
        case .atMe:
            
            return "[\("有人".innerLocalized())@\("你".innerLocalized())]"
        case .atAll:
            
            return "[@\("所有人".innerLocalized())]"
        case .atAllAtMe:
            
            return "[@\("所有人".innerLocalized()) @\("你".innerLocalized())]"
        case .announcement:
            
            return "[\("群公告".innerLocalized())]"
        }
    }
}

extension NotificationElem {
    var opUserIsMe: Bool {
        opUser?.userID == IMController.shared.uid
    }
}

extension GroupMemberInfo {
    public func toSimplePublicUserInfo() -> PublicUserInfo {
        PublicUserInfo(userID: userID!, nickname: nickname, faceURL: faceURL)
    }
}

extension FriendInfo {
    public var showName: String {
        return (remark != nil && remark!.count > 0) ? remark! : (nickname ?? userID!)
    }
}

extension PublicUserInfo {
    public func toFriendInfo() -> FriendInfo {
        FriendInfo(userID: userID!, nickname: nickname, faceURL: faceURL)
    }
    
    public func toUserInfo() -> UserInfo {
        UserInfo(userID: userID!, nickname: nickname, faceURL: faceURL)
    }
}


/// 通知内容
struct systemCustomNotitifyItem : Codable{
    var cont: String?
    var user: systemCustomNotitifyUser?
}

struct systemCustomNotitifyUser : Codable{
    var userID: String?
    var account: String?
    var email: String?
    var nickname: String?
    var faceURL: String?
    var gender: Int?
    var level: Int?
}



class SuperStringUtil {
    
    
    
    /// 获取用户的信息  网站 公司 vip 名字
    static func getUserState(showname: String) -> UserState {
        guard let jsonData = showname.data(using: .utf8) else { return UserState(b: 0, e: 0, v: 0, n: showname)}
        do {
            let user = try JSONDecoder().decode(UserState.self, from: jsonData)
            return user
        } catch {
            return  UserState(b: 0, e: 0, v: 0, n: showname)
        }
    }
    
    static func getUserShowname(showname: String) -> String  {
        let user = getUserState(showname: showname)
        return user.n
    }
    /// 获取用户的tag
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
