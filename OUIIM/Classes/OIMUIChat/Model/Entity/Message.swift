
import ChatLayout
import DifferenceKit
import Foundation
import OUICore
import CoreLocation

// 控制消息出入
// MARK: - 张亚飞打的标记  消息来源 对方或者自己
enum MessageType: Hashable {
    case incoming
    case outgoing
    
    var isIncoming: Bool {
        self == .incoming
    }
}

// 控制已读状态
enum MessageStatus: Hashable {
    case sentFailure
    case sending
    case sent(AttachInfo) // After sending successfully, there will be sending status, read status, etc.
    case received
}

// 控制显示类型
enum MessageRawType: Hashable {
    case normal // 消息正文
    case system // 系统提示消息： eg. xxx加入群聊 xxx撤回了一条消息
    case date   // 日期
}

enum MessageSessionRawType: Hashable {
    case single
    case group
}

enum MediaMessageType: Hashable {
    case image
    case audio
    case video
}

enum TextMessageType: Hashable {
    case text // 普通消息
    case notice // 公告
}

enum NoticeType: Hashable {
    case oa
    case other
}

extension ChatItemAlignment {
    
    var isIncoming: Bool {
        self == .leading
    }
}

enum MentionType: Hashable {
    case none   // 没有at
    case many   // @多人
    case all    // @所有人
}

struct MutedInfo {
    var mutedEndTime: Double = 0
    var mutedText: String = ""
    var muted: Bool = false
    var mutedMe: Bool = false
}

struct DateGroup: Hashable {
    
    var id: String
    var date: Date
    var value: String {
        Date.timeString(date: date)
    }
    
    init(id: String, date: Date) {
        self.id = id
        self.date = date
    }
}

extension DateGroup: Differentiable {
    
    public var differenceIdentifier: Int {
        id.hashValue
    }
    
    public func isContentEqual(to source: DateGroup) -> Bool {
        self == source
    }
}

struct SystemGroup: Hashable {
    
    enum Data: Hashable {
        case text(String)
    }
    
    var id: String
    var value: NSAttributedString
}

extension SystemGroup: Differentiable {
    
    public var differenceIdentifier: Int {
        id.hashValue
    }
    
    public func isContentEqual(to source: SystemGroup) -> Bool {
        self == source
    }
}

struct MessageGroup: Hashable {
    
    var id: String
    var title: String
    var type: MessageType
    
    init(id: String, title: String, type: MessageType) {
        self.id = id
        self.title = title
        self.type = type
    }
    
}

extension MessageGroup: Differentiable {
    
    public var differenceIdentifier: Int {
        id.hashValue
    }
    
    public func isContentEqual(to source: MessageGroup) -> Bool {
        self == source
    }
}

struct AtInfoItem: Hashable {
    var atUserID: String?
    var groupNickname: String?
}

// 设置已读标识，阅后即焚时长
struct AttachInfo: Hashable {
    
    enum ReadedStatus: Hashable {
        case signalReaded(_ readed: Bool)
        case groupReaded(_ readed: Bool, _ allReaded: Bool)
    }
    
    var readedStatus: ReadedStatus = .signalReaded(false)
    var text: String = ""
    var isPriavte: Bool = false
    var duration: Double = 0
    var hasReadTime: Double = 0
}

extension AttachInfo: Differentiable {
    public var differenceIdentifier: Int {
        readedStatus.hashValue
    }
    
    public func isContentEqual(to source: AttachInfo) -> Bool {
        self == source
    }
}

struct MessageEx: Hashable, Codable {
    var audioHasReaded: Bool = false
    var isFace: Bool = false
    var translate: String = "no"
    var translateReslu: String = ""
}

struct TextMessageSource: Hashable {
    var text: String
    var type: TextMessageType = .text
    var ex: String?
}

struct MediaMessageSource: Hashable {
    
    struct Info: Hashable {
        var url: URL! // 远端地址 & 本地完整地址
        var relativePath: String? // 考虑断点续传 沙盒问题
        var size: CGSize = CGSize(width: 120, height: 120)
        
        static func == (lhs: Info, rhs: Info) -> Bool {
            lhs.url == rhs.url && lhs.relativePath == rhs.relativePath
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(url)
            hasher.combine(relativePath)
        }
    }
    
    var image: UIImage?
    var source: Info
    var thumb: Info?
    var duration: Int?
    var ex: MessageEx?
}

struct FileMessageSource: Hashable {
    var url: URL!
    var length: Int = 0
    var name: String?
    var relativePath: String? // 考虑断点续传 & 沙盒问题
}

// 合并消息
struct MergeMessageSource: Hashable {
    var title: String
    var abstractList: [String]?
    var multiMessage: [Message]?
}

// 回复消息
struct QuoteMessageSource: Hashable {
    var sender: String?
    var text: String
    private(set) var attributedString: NSAttributedString?
    var quoteMessageID: String?
    var quote: Message.Data?
}

// 名片消息
struct CardMessageSource: Hashable {
    var user: User
}

// 定位消息
struct LocationMessageSource: Hashable {
    var url: URL?
    var name: String?
    var address: String?
    
    var desc: String = ""
    var latitude: Double = 0 // 纬度
    var longitude: Double = 0 // 经度
}

// mention消息
struct MentionMessageSource: Hashable {
    var text: String?
    private(set) var attributedString: NSAttributedString?
    var atUserList: [String]?
    var atUsersInfo: [AtInfoItem]?
    var quoteMessage: QuoteMessageSource?
    var isAtSelf: Bool = false
}

struct FaceMessageSource: Hashable {
    var localPath: String?
    var url: URL
    var index: Int
}

// MARK: - 张亚飞打的标记  博客消息
struct bokeMessageSource: Hashable, Codable {
//    var title: String?
//    var iconUrl: String?
//    var linkUrl: String?
//    var intro: String?
    let id: Int?
    let sign: Int?
    let userBlogUrl: String?
    let userBlogIntro: String?
    let userBlogName: String?
    let userBlogCreatIp: String?
    let userBlogCreatAffiliatingArea: String?
    let userBlogOrder: Int?
    let userId: String?
    let isDelete: Int?
    let creationTime: String?
    let userBlogIcon: String?
    let changeTime: String?
    
    var state: BokeType {
        switch sign {
        case 0:
            return .normal
        case 1, 4:
            return .wait
        case 2:
            return .refuse
        case 3:
            return .limit
            
        default:
            return.normal
        }
    }
}

enum BokeType {
    case normal
    case wait
    case refuse
    case limit
}


// MARK: - 张亚飞打的标记  通知消息
struct NoticeMessageSource: Hashable {
    
    enum MixType: Int {
        case text = 0
        case textImage = 1
        case textVideo = 2
        case textFile = 3
    }
    
    private(set) var type: NoticeType
    private(set) var detail: String?
    private(set) var avatar: String?
    private(set) var title: String?
    private(set) var text: String?
    private(set) var snapshotUrl: String?
    private(set) var mixType: MixType = .text
    private(set) var derictURL: String?
    private(set) var height: CGFloat?
    
    init(type: NoticeType, detail: String? = nil) {
        self.type = type
        self.detail = detail
        
        guard let detail else { return }
        
        if let value = try? JSONSerialization.jsonObject(with: detail.data(using: .utf8)!, options: .mutableContainers) as? [String: Any] {
            avatar = value["notificationFaceURL"] as? String
            title = value["notificationName"] as? String
            text = value["text"] as? String
            mixType = MixType(rawValue: value["mixType"] as! Int) ?? .text
            derictURL = value["url"] as? String
            
            if let picture = value["pictureElem"] as? [String: Any], let s = picture["sourcePicture"] as? [String: Any] {
                snapshotUrl = s["url"] as? String
                height = s["height"] as? CGFloat
            }
        }
    }
    
    
}





// 自定义消息
// MARK: - 张亚飞打的标记  自定义消息
struct CustomMessageSource: Hashable {
    public enum CustomMessageType: Int {
        case call = 901 // 音视频
        case customEmoji = 902 // emoji
        case tagMessage = 903 // 标签消息
        case moments = 904 // 朋友圈
        case meeting = 905 // 会议
        case blockedByFriend = 910 // 被拉黑
        case deletedByFriend = 911 // 被删除
        
        case boke = 10500 //博客
        case buyVip = 10600 //购买vip
        case vipVisitorWarn = 10601 //vip访客提醒
        case systemNotify = 10700 //系统通知
    }

    var data: String?
    private(set) var attributedString: NSAttributedString?
}

extension CustomMessageSource {
    
    public var value: [String: Any]? {
        if let data = data {
            let obj = try! JSONSerialization.jsonObject(with: data.data(using: .utf8)!) as! [String: Any]
            return obj["data"] as? [String: Any]
        }
        
        return nil
    }
    // MARK: - 张亚飞打的标记   获取博客信息
    public var bokeMessageSource: bokeMessageSource {
        if let value = value {
//            let title = value["title"]
//            let iconUrl = value["iconUrl"]
//            let linkUrl = value["linkUrl"]
//            let intro = value["intro"] ?? "intro"
//            print(intro)
            return OUIIM.bokeMessageSource(id: value["id"] as? Int,
                                           sign: value["sign"] as? Int,
                                           userBlogUrl: value["userBlogUrl"] as? String,
                                           userBlogIntro: value["userBlogIntro"] as? String,
                                           userBlogName: value["userBlogName"] as? String,
                                           userBlogCreatIp: value["userBlogCreatIp"] as? String,
                                           userBlogCreatAffiliatingArea: value["userBlogCreatAffiliatingArea"] as? String,
                                           userBlogOrder: value["userBlogOrder"] as? Int,
                                           userId: value["userId"] as? String,
                                           isDelete: value["isDelete"] as? Int,
                                           creationTime: value["creationTime"] as? String,
                                           userBlogIcon: value["userBlogIcon"] as? String,
                                           changeTime: value["changeTime"] as? String)
        }
        return OUIIM.bokeMessageSource(id: -1, sign: 0, userBlogUrl: "", userBlogIntro: "", userBlogName: "", userBlogCreatIp: "", userBlogCreatAffiliatingArea: "", userBlogOrder: 0, userId: "", isDelete: 0, creationTime: "", userBlogIcon: "", changeTime: "")
    }
    
    // MARK: - 张亚飞打的标记   自定义消息加工
    public var type: CustomMessageType? {
        if let data = data {
            let obj = try! JSONSerialization.jsonObject(with: data.data(using: .utf8)!) as! [String: Any]
            let t = obj["customType"] as! Int
            
            return CustomMessageType(rawValue: t)
        }
        
        return nil
    }
}

// MARK: - 张亚飞打的标记   消息类型
struct Message: Hashable {
    
    indirect enum Data: Hashable {
        
        case text(TextMessageSource)
        
        case attributeText(NSAttributedString)
        
        case url(URL, isLocallyStored: Bool)
        
        case image(MediaMessageSource, isLocallyStored: Bool)
        
        case video(MediaMessageSource, isLocallyStored: Bool) // 视频路径，缩略图路径，时长
        
        case audio(MediaMessageSource, isLocallyStored: Bool)
        
        case file(FileMessageSource, isLocallyStored: Bool) // 文件路径， 名字， 长度
        
        case quote(QuoteMessageSource) // 引用回复， 发送消息的时候不会用到
        
        case merge(MergeMessageSource) // 转发合并
        
        case card(CardMessageSource)
        
        case location(LocationMessageSource)
        
        case mention(MentionMessageSource) // 发送消息的时候不会用到
        
        case notice(NoticeMessageSource)
        
        case custom(CustomMessageSource)
        
        case face(FaceMessageSource, isLocallyStored: Bool)
        
//        case boke(bokeMessageSource)
    }
    
    var id: String
    
    var date: Date
    
    var contentType: MessageRawType
    
    var sessionType: MessageSessionRawType
    
    var data: Data
    
    var owner: User
    
    var type: MessageType
    
    var status: MessageStatus = .sending
    
    var isSelected: Bool = false // 编辑状态使用
    
    var isAnchor: Bool = false
}

extension Message {
    func getSummary() -> String? {
        var abstruct: String?
        
        switch data {
        case .text(let source):
            abstruct = source.type == .notice ? "[公告]" : source.text
        case .attributeText(let value):
            abstruct = value.string
        case .url(_, isLocallyStored: let isLocallyStored):
            abstruct = "[链接]".innerLocalized()
        case .image(_, isLocallyStored: let isLocallyStored):
            abstruct = "[图片]".innerLocalized()
        case .video(_, isLocallyStored: let isLocallyStored):
            abstruct = "[视频]".innerLocalized()
        case .audio(_, isLocallyStored: let isLocallyStored):
            abstruct = "[语音]".innerLocalized()
        case .file(_, isLocallyStored: let isLocallyStored):
            abstruct = "[文件]".innerLocalized()
        case .quote(let value):
            abstruct = value.text
        case .merge(_):
            abstruct = "[合并转发]"
        case .card(_):
            abstruct = "[名片]"
        case .location(_):
            abstruct = "[定位]"
        case .mention(let value):
            abstruct = value.attributedString?.string
//        case .boke(let source):
//            abstruct = "[博客]".innerLocalized()
        case .custom(let source):
            print(source.type?.rawValue)
        default:
            break
        }
        
        return abstruct
    }
}

extension Message: Differentiable {
    
    public var differenceIdentifier: Int {
        id.hashValue
    }
    
    public func isContentEqual(to source: Message) -> Bool {
        self == source
    }
}



/// 通知内容
struct systemCustomNotitifyItem : Codable{
    var count: String?
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


