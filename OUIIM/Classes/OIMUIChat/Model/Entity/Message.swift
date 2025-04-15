
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

// MARK: - 张亚飞打的标记  网站消息
struct bokeMessageSource: Hashable, Codable {
    let type:String?
    let uid: String?
    let hash: String?
    let pwd: String?
    let url: String?
    let logo: String?
    let mark: String?
    let name: String?
}
// MARK: -  公共模版消息
struct commonTemplateSource:Decodable {
    let data: commonTemplateMessageSource?
    let customType: Int?
}
struct commonTemplateMessageSource: Decodable {
    let hash:String?
    let logo: String?
    let title: String?
    let intro: String?
    let action: String?
    let url:String?
    let remark:String?
    let item:commonTemplateItemModel?
    let bt:commonTemplateBtModel?
    let media:commonTemplateMediaModel?
}
struct commonTemplateItemModel: Codable {
    let bg: String?
    let icon: String?
    let name: String?
    let intro: String?
    let action:String?
    let url:String?
    let request_data:String?
}
struct commonTemplateBtModel: Codable {
    let long:commonTemplateBtItemModel?
    let left:commonTemplateBtItemModel?
    let right:commonTemplateBtItemModel?
}
struct commonTemplateBtItemModel: Codable {
    let action:String?
    let url:String?
    let name:String?
    let request_data:String?
}
struct commonTemplateMediaModel: Codable {
    let type:String?
    let media_url:String?
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
        
        case boke = 10500 //网站
        case buyVip = 10600 //购买vip
        case vipVisitorWarn = 10601 //vip访客提醒
        case systemNotify = 10700 //系统通知
        case commonTemplate = 10900 //自定义统一模版
    }

    var data: String?
    var localEx: String?
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
    public var localExValue: [String: Any]? {
        if let localEx = localEx {
            let obj = try! JSONSerialization.jsonObject(with: localEx.data(using: .utf8)!, options: []) as! [String: Any]
            return obj["localEx"] as? [String: Any]
        }
        return nil
    }
    // MARK: - 张亚飞打的标记   获取网站信息
    public var bokeMessageSource: bokeMessageSource {
        if let value = value {
//            let title = value["title"]
//            let iconUrl = value["iconUrl"]
//            let linkUrl = value["linkUrl"]
//            let intro = value["intro"] ?? "intro"
//            print(intro)
            return OUIIM.bokeMessageSource(type:value["type"] as? String,
                                           uid: value["uid"] as? String,
                                           hash: value["hash"] as? String,
                                           pwd: value["pwd"] as? String,
                                           url: value["url"] as? String,
                                           logo: value["logo"] as? String,
                                           mark: value["mark"] as? String,
                                           name: value["name"] as? String)
        }
        return OUIIM.bokeMessageSource(type:"",uid: "", hash: "", pwd: "", url: "", logo: "", mark: "", name: "")
    }
    public var commonTemplateMessageSource: commonTemplateMessageSource {
        if let value = value {
            if let localExValue = localExValue{
                if let res = JsonTool.fromMap(localExValue, toClass:  OUIIM.commonTemplateMessageSource.self){
                    return res
                }else{
                    let long = commonTemplateBtItemModel(action: "", url: "", name: "", request_data: "")
                    return OUIIM.commonTemplateMessageSource(hash: "",logo: "", title: "", intro: "", action: "", url: "", remark: "", item: OUIIM.commonTemplateItemModel(bg: "", icon: "", name: "", intro: "", action: "", url: "", request_data: ""), bt: OUIIM.commonTemplateBtModel(long: long, left: long, right: long), media: OUIIM.commonTemplateMediaModel(type: "", media_url: ""))
                }
            }else{
                if let res = JsonTool.fromMap(value, toClass:  OUIIM.commonTemplateMessageSource.self){
                    return res
                }else{
                    let long = commonTemplateBtItemModel(action: "", url: "", name: "", request_data: "")
                    return OUIIM.commonTemplateMessageSource(hash: "",logo: "", title: "", intro: "", action: "", url: "", remark: "", item: OUIIM.commonTemplateItemModel(bg: "", icon: "", name: "", intro: "", action: "", url: "", request_data: ""), bt: OUIIM.commonTemplateBtModel(long: long, left: long, right: long), media: OUIIM.commonTemplateMediaModel(type: "", media_url: ""))
                }
            }
            
        }
        let long = commonTemplateBtItemModel(action: "", url: "", name: "", request_data: "")
        return OUIIM.commonTemplateMessageSource(hash: "",logo: "", title: "", intro: "", action: "", url: "", remark: "", item: OUIIM.commonTemplateItemModel(bg: "", icon: "", name: "", intro: "", action: "", url: "", request_data: ""), bt: OUIIM.commonTemplateBtModel(long: long, left: long, right: long), media: OUIIM.commonTemplateMediaModel(type: "", media_url: ""))
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
//            abstruct = "[网站]".innerLocalized()
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


