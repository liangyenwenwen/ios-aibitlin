

import ChatLayout
import Foundation
import UIKit
import RxSwift

// MARK: - 张亚飞打的标记  消息cell

// 调整成右侧头像
//typealias TextMessageCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, TextMessageView, StatusView>>>
typealias TextMessageCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, TextMessageView, ChatAvatarView>>>

@available(iOS 13, *)
typealias URLCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, URLView, ChatAvatarView>>>

typealias ImageCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, ImageView, ChatAvatarView>>>
typealias VideoCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, VideoView, ChatAvatarView>>>
typealias AudioCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, AudioView, ChatAvatarView>>>
typealias FileCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, FileView, ChatAvatarView>>>
typealias ReplyCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, ReplyView, ChatAvatarView>>>
typealias MergeCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, MergeView, ChatAvatarView>>>
typealias CardCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, CardView, ChatAvatarView>>>
typealias LocationCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, LocationView, ChatAvatarView>>>
typealias NoticeCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, NoticeView, ChatAvatarView>>>

// MARK: - 张亚飞打的标记  初始系统通知
typealias OANoticeCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, OANoticeView, ChatAvatarView>>>
typealias CustomViewCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, CustomView, ChatAvatarView>>>
typealias BlankCustomViewCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, BlankCustomView, ChatAvatarView>>>

// MARK: - 张亚飞打的标记  自定义BokeCell
typealias BokeCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, YFBokeView, ChatAvatarView>>>
typealias CommonTemplateCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<ChatAvatarView, YFCommonTemplateView, ChatAvatarView>>>

// MARK: - 张亚飞打的标记  没有头像的消息Cell
typealias UserTitleCollectionCell = ContainerCollectionViewCell<SwappingContainerView<EdgeAligningView<UILabel>, UIImageView>>
typealias TitleCollectionCell = ContainerCollectionViewCell<SystemTipsView>

// MARK: - 张亚飞打的标记  通知消息
typealias VipNormolCollectionCell = ContainerCollectionViewCell<YFVipNormalView>
typealias VipContactCollectionCell = ContainerCollectionViewCell<YFVipContactView>


typealias TypingIndicatorCollectionCell = ContainerCollectionViewCell<MessageContainerView<EditingAccessoryView, MainContainerView<VoidViewFactory, TypingIndicator, VoidViewFactory>>>

typealias TextTitleView = ContainerCollectionReusableView<UILabel>

final class DefaultChatCollectionDataSource: NSObject, ChatCollectionDataSource {
    
    var isSystemNotify: Bool
    
    private var reloadDelegate: ReloadDelegate
    
    public unowned var gestureDelegate: GestureDelegate?
    
    private unowned var editingDelegate: EditingAccessoryControllerDelegate
    
    private let editNotifier: EditNotifier
    
    private let swipeNotifier: SwipeNotifier
    
    private var delayShowIndicators: [String: Bool] = [:] // TODO: When developing an app, it is best to remove this.
        
    var sections: [Section] = [] {
        didSet {
            oldSections = oldValue
        }
    }
    
    var mediaImageViews: [String: Int] = [:]
    
    private var oldSections: [Section] = []
    
    init(editNotifier: EditNotifier,
         swipeNotifier: SwipeNotifier,
         reloadDelegate: ReloadDelegate,
         editingDelegate: EditingAccessoryControllerDelegate, isSystemNotify: Bool) {
        self.reloadDelegate = reloadDelegate
        self.editingDelegate = editingDelegate
        self.editNotifier = editNotifier
        self.swipeNotifier = swipeNotifier
        self.isSystemNotify = isSystemNotify
    }
    
    deinit {
        print("====\(self) deinit")
    }
    
    func prepare(with collectionView: UICollectionView) {
        collectionView.register(TextMessageCollectionCell.self, forCellWithReuseIdentifier: TextMessageCollectionCell.reuseIdentifier)
        collectionView.register(ImageCollectionCell.self, forCellWithReuseIdentifier: ImageCollectionCell.reuseIdentifier)
        collectionView.register(VideoCollectionCell.self, forCellWithReuseIdentifier: VideoCollectionCell.reuseIdentifier)
        collectionView.register(AudioCollectionCell.self, forCellWithReuseIdentifier: AudioCollectionCell.reuseIdentifier)
        collectionView.register(FileCollectionCell.self, forCellWithReuseIdentifier: FileCollectionCell.reuseIdentifier)
        collectionView.register(ReplyCollectionCell.self, forCellWithReuseIdentifier: ReplyCollectionCell.reuseIdentifier)
        collectionView.register(MergeCollectionCell.self, forCellWithReuseIdentifier: MergeCollectionCell.reuseIdentifier)
        collectionView.register(CardCollectionCell.self, forCellWithReuseIdentifier: CardCollectionCell.reuseIdentifier)
        collectionView.register(LocationCollectionCell.self, forCellWithReuseIdentifier: LocationCollectionCell.reuseIdentifier)
        collectionView.register(NoticeCollectionCell.self, forCellWithReuseIdentifier: NoticeCollectionCell.reuseIdentifier)
        collectionView.register(OANoticeCollectionCell.self, forCellWithReuseIdentifier: OANoticeCollectionCell.reuseIdentifier)
        collectionView.register(CustomViewCollectionCell.self, forCellWithReuseIdentifier: CustomViewCollectionCell.reuseIdentifier)
        collectionView.register(BlankCustomViewCollectionCell.self, forCellWithReuseIdentifier: BlankCustomViewCollectionCell.reuseIdentifier)
        collectionView.register(UserTitleCollectionCell.self, forCellWithReuseIdentifier: UserTitleCollectionCell.reuseIdentifier)
        collectionView.register(TitleCollectionCell.self, forCellWithReuseIdentifier: TitleCollectionCell.reuseIdentifier)
        collectionView.register(TypingIndicatorCollectionCell.self, forCellWithReuseIdentifier: TypingIndicatorCollectionCell.reuseIdentifier)
        collectionView.register(TextTitleView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TextTitleView.reuseIdentifier)
        collectionView.register(TextTitleView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: TextTitleView.reuseIdentifier)
        
        // MARK: - 张亚飞打的标记  自定义消息注册
        collectionView.register(BokeCollectionCell.self, forCellWithReuseIdentifier: BokeCollectionCell.reuseIdentifier)
        collectionView.register(CommonTemplateCollectionCell.self, forCellWithReuseIdentifier: CommonTemplateCollectionCell.reuseIdentifier)
        collectionView.register(VipNormolCollectionCell.self, forCellWithReuseIdentifier: VipNormolCollectionCell.reuseIdentifier)
        collectionView.register(VipContactCollectionCell.self, forCellWithReuseIdentifier: VipContactCollectionCell.reuseIdentifier)
        
        if #available(iOS 13.0, *) {
            collectionView.register(URLCollectionCell.self, forCellWithReuseIdentifier: URLCollectionCell.reuseIdentifier)
        }
    }
    
    private func createTextCell(collectionView: UICollectionView,
                                messageId: String,
                                isSelected: Bool,
                                indexPath: IndexPath,
                                text: String? = nil,
                                attributedString: NSAttributedString? = nil,
                                anchor: Bool = false,
                                date: Date,
                                alignment: ChatItemAlignment,
                                user: User,
                                bubbleType: Cell.BubbleType,
                                status: MessageStatus,
                                messageType: MessageType,
                                sessionType: MessageSessionRawType,
                                messageEx:String? = nil,
                                isTop:Bool,
                                lastID: String?) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextMessageCollectionCell.reuseIdentifier, for: indexPath) as! TextMessageCollectionCell
        
        let container = cell.customView
        let mainMessageView = container.customView
        let bubbleView = mainMessageView.maskedView
        
        setupMessageContainerView(container, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(mainMessageView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        setupSwipeHandlingAccessory(mainMessageView, date: date, accessoryConnectingView: cell.customView)
        
        let controller = TextMessageController(messageID: messageId,
                                               text: text,
                                               attributedString: attributedString,
                                               highlight: anchor,
                                               type: messageType,
                                               bubbleController: buildTextBubbleController(bubbleView: bubbleView,
                                                                                           messageType: messageType,
                                                                                           bubbleType: bubbleType), 
                                               userID: user.id, messageEx: messageEx)
        controller.longPress = { [weak self] sourceView, point in
            self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
        }
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        cell.delegate = bubbleView.customView
    
        return cell
    }
    
    @available(iOS 13, *)
    private func createURLCell(collectionView: UICollectionView, messageId: String, isSelected: Bool, indexPath: IndexPath, url: URL, date: Date, alignment: ChatItemAlignment, user: User, bubbleType: Cell.BubbleType, status: MessageStatus, messageType: MessageType,
                               sessionType: MessageSessionRawType,
                               isTop:Bool,
                               lastID: String?) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: URLCollectionCell.reuseIdentifier, for: indexPath) as! URLCollectionCell
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        
        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
        
        let bubbleView = cell.customView.customView.maskedView
        let controller = URLController(url: url,
                                       messageId: messageId,
                                       bubbleController: buildBezierBubbleController(for: bubbleView, messageType: messageType, bubbleType: bubbleType))
        
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        controller.delegate = reloadDelegate
        cell.delegate = bubbleView.customView
        
        return cell
    }
    
    private func createImageCell(collectionView: UICollectionView,
                                 messageId: String,
                                 isSelected: Bool,
                                 indexPath: IndexPath,
                                 alignment: ChatItemAlignment,
                                 user: User,
                                 source: MediaMessageSource,
                                 forVideo: Bool = false,
                                 date: Date,
                                 bubbleType: Cell.BubbleType,
                                 status: MessageStatus,
                                 messageType: MessageType,
                                 sessionType: MessageSessionRawType,
                                 isTop:Bool,
                                 lastID: String?) -> ImageCollectionCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.reuseIdentifier, for: indexPath) as! ImageCollectionCell
        
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        
        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
        
        let bubbleView = cell.customView.customView.maskedView
        let controller = ImageController(source: source,
                                         messageId: messageId,
                                         bubbleController: buildBezierBubbleController(for: bubbleView, messageType: messageType, bubbleType: bubbleType))
        
        controller.longPress = { [weak self] sourceView, point in
            self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
        }
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView
        mediaImageViews[messageId] = messageId.hash
        
        return cell
    }
    
    private func createVideoCell(collectionView: UICollectionView,
                                 messageId: String,
                                 isSelected: Bool,
                                 indexPath: IndexPath,
                                 alignment: ChatItemAlignment,
                                 user: User,
                                 source: MediaMessageSource,
                                 forVideo: Bool = false,
                                 date: Date,
                                 bubbleType: Cell.BubbleType,
                                 status: MessageStatus,
                                 messageType: MessageType,
                                 sessionType: MessageSessionRawType,
                                 isTop:Bool,
                                 lastID: String?) -> VideoCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionCell.reuseIdentifier, for: indexPath) as! VideoCollectionCell
        
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        
        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
        
        let bubbleView = cell.customView.customView.maskedView
        let controller = VideoController(source: source,
                                         messageId: messageId,
                                         bubbleController: buildBezierBubbleController(for: bubbleView, messageType: messageType, bubbleType: bubbleType), messageType: messageType)
        
        controller.longPress = { [weak self] sourceView, point in
            self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
        }
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView
        mediaImageViews[messageId] = messageId.hash

        return cell
    }
    
    private func createAudioCell(collectionView: UICollectionView,
                                 messageId: String,
                                 isSelected: Bool,
                                 indexPath: IndexPath,
                                 alignment: ChatItemAlignment,
                                 user: User,
                                 source: MediaMessageSource,
                                 forVideo: Bool = false,
                                 date: Date,
                                 bubbleType: Cell.BubbleType,
                                 status: MessageStatus,
                                 messageType: MessageType,
                                 sessionType: MessageSessionRawType,
                                 isTop:Bool,
                                 lastID: String?) -> AudioCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AudioCollectionCell.reuseIdentifier, for: indexPath) as! AudioCollectionCell
        
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        
        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
        
        let bubbleView = cell.customView.customView.maskedView
        let controller = AudioController(source: source,
                                         messageId: messageId,
                                         messageType: messageType,
                                         bubbleController: buildTextBubbleController(bubbleView: bubbleView,
                                                                                     messageType: messageType,
                                                                                     bubbleType: bubbleType))
        
        controller.longPress = { [weak self] sourceView, point in
            self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
        }
        
        controller.onTap = { [weak self] in
            cell.customView.customView.contentContainer.showDotView(false)
            self?.gestureDelegate?.onTap(with: indexPath)
        }
        // Unclicked voice message needs to display a red dot.
        if messageType == .incoming, source.ex?.audioHasReaded == false {
            cell.customView.customView.contentContainer.showDotView(true)
        }
        
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView

        return cell
    }
    
    private func createFileCell(collectionView: UICollectionView,
                                 messageId: String,
                                isSelected: Bool,
                                 indexPath: IndexPath,
                                 alignment: ChatItemAlignment,
                                 user: User,
                                 source: FileMessageSource,
                                isLocallyStored: Bool = false,
                                 date: Date,
                                 bubbleType: Cell.BubbleType,
                                 status: MessageStatus,
                                 messageType: MessageType,
                                sessionType: MessageSessionRawType,
                                isTop:Bool,
                                lastID: String?) -> FileCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FileCollectionCell.reuseIdentifier, for: indexPath) as! FileCollectionCell
        
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
        
        let bubbleView = cell.customView.customView.maskedView
        let controller = FileController(source: source,
                                        isLocallyStored: isLocallyStored,
                                         messageId: messageId,
                                         bubbleController: buildBlankBubbleController(bubbleView: bubbleView,
                                                                                     messageType: messageType,
                                                                                     bubbleType: bubbleType))
        
        controller.longPress = { [weak self] sourceView, point in
            self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
        }
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView
        
        return cell
    }
    
    private func createReplyCell(collectionView: UICollectionView,
                                messageId: String,
                                isSelected: Bool,
                                indexPath: IndexPath,
                                 source: QuoteMessageSource,
                                attributedString: NSAttributedString? = nil,
                                date: Date,
                                alignment: ChatItemAlignment,
                                user: User,
                                bubbleType: Cell.BubbleType,
                                status: MessageStatus,
                                messageType: MessageType,
                                 sessionType: MessageSessionRawType,
                                 isTop:Bool,
                                 lastID: String?) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReplyCollectionCell.reuseIdentifier, for: indexPath) as! ReplyCollectionCell
        
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
        
        let bubbleView = cell.customView.customView.maskedView
        let controller = ReplyViewController(source: source,
                                             messageID: messageId,
                                             type: messageType,
                                             bubbleController: buildReplyBubbleController(bubbleView: bubbleView,
                                                                                         messageType: messageType,
                                                                                         bubbleType: bubbleType))
        
        controller.longPress = { [weak self] sourceView, point in
            self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
        }
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView
        mediaImageViews[messageId] = messageId.hash

        return cell
    }
    
    private func createMergeCell(collectionView: UICollectionView,
                                messageId: String,
                                isSelected: Bool,
                                indexPath: IndexPath,
                                 source: MergeMessageSource,
                                attributedString: NSAttributedString? = nil,
                                date: Date,
                                alignment: ChatItemAlignment,
                                user: User,
                                bubbleType: Cell.BubbleType,
                                status: MessageStatus,
                                messageType: MessageType,
                                 sessionType: MessageSessionRawType,
                                 isTop:Bool,
                                 lastID: String?) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MergeCollectionCell.reuseIdentifier, for: indexPath) as! MergeCollectionCell
        
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
        
        let bubbleView = cell.customView.customView.maskedView
        let controller = MergeController(source: source,
                                             messageID: messageId,
                                             bubbleController: buildBlankBubbleController(bubbleView: bubbleView,
                                                                                         messageType: messageType,
                                                                                         bubbleType: bubbleType))
        
        controller.longPress = { [weak self] sourceView, point in
            self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
        }
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView
        
        return cell
    }
    
    private func createCardCell(collectionView: UICollectionView,
                                messageId: String,
                                isSelected: Bool,
                                indexPath: IndexPath,
                                source: CardMessageSource,
                                date: Date,
                                alignment: ChatItemAlignment,
                                user: User,
                                bubbleType: Cell.BubbleType,
                                status: MessageStatus,
                                messageType: MessageType,
                                sessionType: MessageSessionRawType,
                                isTop:Bool,
                                lastID: String?) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardCollectionCell.reuseIdentifier, for: indexPath) as! CardCollectionCell
        
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
        
        let bubbleView = cell.customView.customView.maskedView
        let controller = CardController(source: source,
                                             messageID: messageId,
                                             bubbleController: buildBlankBubbleController(bubbleView: bubbleView,
                                                                                         messageType: messageType,
                                                                                         bubbleType: bubbleType))
        
        controller.longPress = { [weak self] sourceView, point in
            self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
        }
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView
        
        return cell
    }
    
    private func createLocationCell(collectionView: UICollectionView,
                                messageId: String,
                                isSelected: Bool,
                                indexPath: IndexPath,
                                source: LocationMessageSource,
                                date: Date,
                                alignment: ChatItemAlignment,
                                user: User,
                                bubbleType: Cell.BubbleType,
                                status: MessageStatus,
                                messageType: MessageType,
                                    sessionType: MessageSessionRawType,
                                    isTop:Bool,
                                    lastID: String?) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LocationCollectionCell.reuseIdentifier, for: indexPath) as! LocationCollectionCell
        
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
        
        let bubbleView = cell.customView.customView.maskedView
        let controller = LocationController(source: source,
                                             messageID: messageId,
                                             bubbleController: buildBlankBubbleController(bubbleView: bubbleView,
                                                                                         messageType: messageType,
                                                                                         bubbleType: bubbleType))
        
        controller.longPress = { [weak self] sourceView, point in
            self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
        }
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView
        
        return cell
    }
    
    private func createGroupNoticeCell(collectionView: UICollectionView,
                                messageId: String,
                                isSelected: Bool,
                                indexPath: IndexPath,
                                source: TextMessageSource,
                                date: Date,
                                alignment: ChatItemAlignment,
                                user: User,
                                bubbleType: Cell.BubbleType,
                                status: MessageStatus,
                                messageType: MessageType,
                                       sessionType: MessageSessionRawType,
                                       isTop:Bool,
                                       lastID: String?) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeCollectionCell.reuseIdentifier, for: indexPath) as! NoticeCollectionCell
        
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: false, enableSelected: false, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
        
        let bubbleView = cell.customView.customView.maskedView
        let controller = NoticeViewController(text: source.text,
                                             bubbleController: buildBlankBubbleController(bubbleView: bubbleView,
                                                                                         messageType: messageType,
                                                                                         bubbleType: bubbleType))
        
        controller.longPress = { [weak self] sourceView, point in
            self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
        }
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView
        
        return cell
    }
    
    private func createNoticeCell(collectionView: UICollectionView,
                                messageId: String,
                                isSelected: Bool,
                                indexPath: IndexPath,
                                source: NoticeMessageSource,
                                date: Date,
                                alignment: ChatItemAlignment,
                                user: User,
                                bubbleType: Cell.BubbleType,
                                status: MessageStatus,
                                messageType: MessageType,
                                  sessionType: MessageSessionRawType,
                                  isTop:Bool,
                                  lastID: String?) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OANoticeCollectionCell.reuseIdentifier, for: indexPath) as! OANoticeCollectionCell
        
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        
        let bubbleView = cell.customView.customView.maskedView
        let controller = OANoticeViewController(messageID: messageId,
                                                source: source,
                                             bubbleController: buildBlankBubbleController(bubbleView: bubbleView,
                                                                                         messageType: messageType,
                                                                                         bubbleType: bubbleType))
        
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView
        
        return cell
    }
    
    // MARK: - 张亚飞打的标记   创建自定义cell
    private func createCustomCell(collectionView: UICollectionView,
                                messageId: String,
                                isSelected: Bool,
                                indexPath: IndexPath,
                                source: CustomMessageSource,
                                anchor: Bool = false,
                                date: Date,
                                alignment: ChatItemAlignment,
                                user: User,
                                bubbleType: Cell.BubbleType,
                                status: MessageStatus,
                                messageType: MessageType,
                                  sessionType: MessageSessionRawType,
                                  isTop:Bool,
                                  lastID: String?) -> UICollectionViewCell {
        
        if source.type == .meeting {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BlankCustomViewCollectionCell.reuseIdentifier, for: indexPath) as! BlankCustomViewCollectionCell
            
            setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
            setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
            setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
            
            let bubbleView = cell.customView.customView.maskedView
            
            let bubbleController = buildBlankBubbleController(bubbleView: bubbleView, messageType: messageType, bubbleType: bubbleType)
            
            let controller = CustomViewController(source: source,
                                                  messageID: messageId,
                                                  highlight: anchor,
                                                  type: messageType,
                                                  bubbleController: bubbleController, messageType: messageType)
            
            controller.longPress = { [weak self] sourceView, point in
                self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
            }
            bubbleView.customView.setup(with: controller)
            controller.delegate = reloadDelegate
            cell.delegate = bubbleView.customView
            
            return cell
        } else if  source.type == .boke{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BokeCollectionCell.reuseIdentifier, for: indexPath) as! BokeCollectionCell
//            测试修改
//            setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: .fullWidth)
//            setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: .fullWidth, bubble: bubbleType, status: status, sessionType: sessionType)
//            setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
            setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
            setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
            setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
            
            let bubbleView = cell.customView.customView.maskedView
            let controller = YFBokeController(source: source.bokeMessageSource,
                                                 messageID: messageId,
                                                 bubbleController: buildBlankBubbleController(bubbleView: bubbleView,
                                                                                             messageType: messageType,
                                                                                             bubbleType: bubbleType))
            
            controller.longPress = { [weak self] sourceView, point in
                self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
            }
            controller.delegate = reloadDelegate
            bubbleView.customView.setup(with: controller)
            controller.view = bubbleView.customView
            cell.delegate = bubbleView.customView
            
            return cell
            
        }else if  source.type == .commonTemplate{
            //公共消息
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommonTemplateCollectionCell.reuseIdentifier, for: indexPath) as! CommonTemplateCollectionCell
            setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected,enableSelected: false,alignment: alignment)
            setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
            setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
            
            let bubbleView = cell.customView.customView.maskedView
            let controller = YFCommonTemplateController(source: source,
                                                 messageID: messageId,
                                                 bubbleController: buildBlankBubbleController(bubbleView: bubbleView,
                                                                                             messageType: messageType,
                                                                                              bubbleType: bubbleType))
            
            controller.longPress = { [weak self] sourceView, point in
                self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
            }
            controller.delegate = reloadDelegate
            bubbleView.customView.setup(with: controller)
            controller.view = bubbleView.customView
            cell.delegate = bubbleView.customView
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomViewCollectionCell.reuseIdentifier, for: indexPath) as! CustomViewCollectionCell
            
            setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
            setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
            setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
            
            let bubbleView = cell.customView.customView.maskedView
            
            let bubbleController = buildTextBubbleController(bubbleView: bubbleView, messageType: messageType, bubbleType: bubbleType)
            
            let controller = CustomViewController(source: source,
                                                  messageID: messageId,
                                                  highlight: anchor,
                                                  type: messageType,
                                                  bubbleController: bubbleController, messageType: messageType)
            
            controller.longPress = { [weak self] sourceView, point in
                self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
            }
            bubbleView.customView.setup(with: controller)
            controller.delegate = reloadDelegate
            cell.delegate = bubbleView.customView
            
            return cell
        }
    }
    
    private func createFaceCell(collectionView: UICollectionView,
                                 messageId: String,
                                 isSelected: Bool,
                                 indexPath: IndexPath,
                                 alignment: ChatItemAlignment,
                                 user: User,
                                 source: FaceMessageSource,
                                 forVideo: Bool = false,
                                 date: Date,
                                 bubbleType: Cell.BubbleType,
                                 status: MessageStatus,
                                 messageType: MessageType,
                                sessionType: MessageSessionRawType,
                                isTop:Bool,
                                lastID: String?) -> ImageCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.reuseIdentifier, for: indexPath) as! ImageCollectionCell
        
        setupMessageContainerView(cell.customView, messageId: messageId, isSelected: isSelected, alignment: alignment)
        setupMainMessageView(cell.customView.customView, user: user, date: date, messageID: messageId, alignment: alignment, bubble: bubbleType, status: status, sessionType: sessionType, isTop: isTop, lastID: lastID)
        
        setupSwipeHandlingAccessory(cell.customView.customView, date: date, accessoryConnectingView: cell.customView)
        
        let imageSrouce = MediaMessageSource(source: MediaMessageSource.Info(url: source.url), thumb: MediaMessageSource.Info(url: source.url), ex: MessageEx(isFace: true))
        let bubbleView = cell.customView.customView.maskedView
        let controller = ImageController(source: imageSrouce,
                                         messageId: messageId,
                                         bubbleController: buildBezierBubbleController(for: bubbleView, messageType: messageType, bubbleType: bubbleType))
        
        controller.longPress = { [weak self] sourceView, point in
            self?.gestureDelegate?.longPress(with: indexPath, sourceView: sourceView, point: point)
        }
        controller.delegate = reloadDelegate
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.delegate = bubbleView.customView
        mediaImageViews[messageId] = messageId.hash

        return cell
    }
    
    private func createTypingIndicatorCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypingIndicatorCollectionCell.reuseIdentifier, for: indexPath) as! TypingIndicatorCollectionCell
        let alignment = ChatItemAlignment.leading
        cell.customView.alignment = alignment
        let bubbleView = cell.customView.customView.maskedView
        
        let controller = TypingIndicatorController(bubbleController: buildBlankBubbleController(bubbleView: bubbleView,
                                                                                                messageType: .incoming,
                                                                                                bubbleType: .normal))
        bubbleView.customView.setup(with: controller)
        controller.view = bubbleView.customView
        cell.customView.accessoryView?.isHiddenSafe = true
        
        return cell
    }
    // 名字
    private func createGroupTitle(collectionView: UICollectionView, indexPath: IndexPath, alignment: ChatItemAlignment, title: String) -> UserTitleCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserTitleCollectionCell.reuseIdentifier, for: indexPath) as! UserTitleCollectionCell
        cell.customView.spacing = 2
        
        cell.customView.customView.customView.text = title
        cell.customView.customView.customView.preferredMaxLayoutWidth = (collectionView.collectionViewLayout as? CollectionViewChatLayout)?.layoutFrame.width ?? collectionView.frame.width
        cell.customView.customView.customView.font = .f10
        cell.customView.customView.flexibleEdges = [.top]
        cell.customView.accessoryView.isHidden = true
        cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 52, bottom: 0, right: 52)
        
        return cell
    }
    
    // 设置时间组cell/系统提示cell
    // MARK: - 张亚飞打的标记 没有头像的Cell
    private func createTipsTitle(collectionView: UICollectionView,
                                 indexPath: IndexPath,
                                 alignment: ChatItemAlignment,
                                 title: String? = nil,
                                 attributeTitle: NSAttributedString? = nil, 
                                 enableBackgroundColor: Bool = false, needHide: Bool = false) -> TitleCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionCell.reuseIdentifier, for: indexPath) as! TitleCollectionCell
        
        let bubbleView = cell.customView
        let controller = SystemTipsViewController(text: title,
                                               attributedString: attributeTitle,
                                                  enableBackgroundColor: enableBackgroundColor, needHide: needHide)
        bubbleView.setup(with: controller)
        controller.delegate = reloadDelegate
        cell.delegate = bubbleView
        
        return cell
    }
    
    ///测试修改
    private func createVipNormalMessage(collectionView: UICollectionView,
                                        indexPath: IndexPath,
                                        message: Message,
                                        source:NoticeMessageSource) -> VipNormolCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VipNormolCollectionCell.reuseIdentifier, for: indexPath) as! VipNormolCollectionCell
        
        let bubbleView = cell.customView
        let controller = YFVipNormalViewController(message: message, source: source)
        bubbleView.setup(with: controller)
        controller.delegate = reloadDelegate
        cell.delegate = bubbleView
        
        return cell
    }
    private func createVipContactMessage(collectionView: UICollectionView,
                                 indexPath: IndexPath,
                                 alignment: ChatItemAlignment,
                                 title: String? = nil,
                                 attributeTitle: NSAttributedString? = nil,
                                 enableBackgroundColor: Bool = false) -> VipContactCollectionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VipContactCollectionCell.reuseIdentifier, for: indexPath) as! VipContactCollectionCell
        
        let bubbleView = cell.customView
        let controller = SystemTipsViewController(text: title,
                                               attributedString: attributeTitle,
                                                  enableBackgroundColor: enableBackgroundColor)
//        bubbleView.setup(with: controller)
        controller.delegate = reloadDelegate
        cell.delegate = bubbleView
        
        return cell
    }
    
    
    
    
    private let disposeBag = DisposeBag()
    // 设置编辑状态
    private func setupMessageContainerView(_ messageContainerView: MessageContainerView<EditingAccessoryView, some Any>, messageId: String, isSelected: Bool, enableSelected: Bool = true, alignment: ChatItemAlignment) {
        
        let tap = UITapGestureRecognizer()
        messageContainerView.subviews.first?.isUserInteractionEnabled = true
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.gestureDelegate?.onTapEdgeAligningView()
        }).disposed(by: disposeBag)
        
        messageContainerView.subviews.first?.addGestureRecognizer(tap)
        
        messageContainerView.alignment = alignment
        if let accessoryView = messageContainerView.accessoryView {
            editNotifier.add(delegate: accessoryView)
            accessoryView.setIsEditing(editNotifier.isEditing)
            
            let controller = EditingAccessoryController(messageId: messageId)
            controller.view = accessoryView
            controller.delegate = editingDelegate
            accessoryView.setup(with: controller, isSelected: isSelected, enableSelected: enableSelected)
            
            // The main function is to allow you to click on the entire cell to select it when in the editing state without having to click on the button.
            messageContainerView.subviews.first?.isUserInteractionEnabled = !editNotifier.isEditing
            
            if enableSelected {
                let tap = UITapGestureRecognizer()
                messageContainerView.addGestureRecognizer(tap)
                tap.rx.event.subscribe(onNext: { [weak self, weak accessoryView] _ in
                    guard let self else { return }
                    
                    if editNotifier.isEditing {
                        editingDelegate.selecteMessage(with: messageId)
                        accessoryView?.toggleState()
                    }
                }).disposed(by: disposeBag)
            }
        }
    }
    
    /*private func setupCellLayoutView(_ cellView: CellLayoutContainerView<ChatAvatarView, some Any, StatusView>,
     user: User,
     alignment: ChatItemAlignment,
     bubble: Cell.BubbleType,
     status: MessageStatus) {
     cellView.alignment = .bottom
     cellView.leadingView?.isHiddenSafe = !alignment.isIncoming
     cellView.leadingView?.alpha = alignment.isIncoming ? 1 : 0
     cellView.trailingView?.isHiddenSafe = alignment.isIncoming
     cellView.trailingView?.alpha = alignment.isIncoming ? 0 : 1
     cellView.trailingView?.setup(with: status)
     
     if let avatarView = cellView.leadingView {
     let avatarViewController = AvatarViewController(user: user, bubble: bubble)
     avatarView.setup(with: avatarViewController)
     avatarViewController.view = avatarView
     }
     }*/
    // 这里没有右边头像, 是个已读标记
    /*private func setupMainMessageView(_ cellView: MainContainerView<ChatAvatarView, some Any, StatusView>,
     user: User,
     alignment: ChatItemAlignment,
     bubble: Cell.BubbleType,
     status: MessageStatus) {
     cellView.containerView.alignment = .bottom
     cellView.containerView.leadingView?.isHiddenSafe = !alignment.isIncoming
     cellView.containerView.leadingView?.alpha = alignment.isIncoming ? 1 : 0
     cellView.containerView.trailingView?.isHiddenSafe = alignment.isIncoming
     cellView.containerView.trailingView?.alpha = alignment.isIncoming ? 0 : 1
     cellView.containerView.trailingView?.setup(with: status)
     if let avatarView = cellView.containerView.leadingView {
     let avatarViewController = AvatarViewController(user: user, bubble: bubble)
     avatarView.setup(with: avatarViewController)
     avatarViewController.view = avatarView
     }
     }
     */
    
    // MARK: - 张亚飞打的标记 设置头像
    // 设置头像
    private func setupMainMessageView(_ cellView: MainContainerView<ChatAvatarView, some Any, ChatAvatarView>,
                                      user: User,
                                      date: Date,
                                      messageID: String,
                                      alignment: ChatItemAlignment,
                                      bubble: Cell.BubbleType,
                                      status: MessageStatus,
                                      sessionType: MessageSessionRawType,
                                      isTop:Bool,
                                      lastID: String?) {
        cellView.containerView.alignment = .top
        cellView.containerView.leadingView?.isHiddenSafe = !alignment.isIncoming
        cellView.containerView.leadingView?.alpha = alignment.isIncoming ? 1 : 0
        cellView.containerView.trailingView?.isHiddenSafe = alignment.isIncoming
        cellView.containerView.trailingView?.alpha = alignment.isIncoming ? 0 : 1
        
        
        if delayShowIndicators[messageID] == nil {
            delayShowIndicators[messageID] = false
        }
        
        // MARK: - 张亚飞打的标记  隐藏每条消息发送时间
        if sessionType == .group && (isTop || ( !isTop && user.id != lastID) ) && alignment.isIncoming{
            cellView.contentContainer.setTitle(title: "\(sessionType == .single ? "" : user.name)", messageType: alignment.isIncoming ? .incoming : .outgoing)
        } else {
            cellView.contentContainer.setTitle(title: nil, messageType: alignment.isIncoming ? .incoming : .outgoing)
        }
        
//        cellView.contentContainer.setTitle(title: "\(sessionType == .single ? "" : user.name) \(Date.timeString(date: date))", messageType: alignment.isIncoming ? .incoming : .outgoing)
        cellView.contentContainer.showStutusIndicator(false)
        cellView.contentContainer.showErrorButton(false)
        cellView.contentContainer.setReadStatus(title: nil)
        
        // MARK: - 张亚飞打的标记  隐藏已读未读lbl
        cellView.contentContainer.hidenReadStatusLbl(true)
        
        switch status {
        case .sentFailure:
            delayShowIndicators[messageID] = nil
            
            cellView.contentContainer.showStutusIndicator(false)
            cellView.contentContainer.showErrorButton(true) { [weak self] in
                self?.reloadDelegate.resendMessage(messageID: messageID)
                self?.delayShowIndicators[messageID] = true
            }
        case .sending:
            if delayShowIndicators[messageID] == true {
                cellView.contentContainer.showStutusIndicator()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self, cellView] in
                    if delayShowIndicators[messageID] == false {
                        delayShowIndicators[messageID] = true
                        cellView.contentContainer.showStutusIndicator()
                    }
                }
            }
        case .received:
            delayShowIndicators[messageID] = nil

            cellView.contentContainer.showStutusIndicator(false)
            
            //测试修改  已读未读 隐藏
        case .sent(let info):
            delayShowIndicators[messageID] = nil

            cellView.contentContainer.showStutusIndicator(false)
            if !alignment.isIncoming {
                var allReaded = false
                
                switch info.readedStatus {
                case .signalReaded(let readed):
                    allReaded = readed
                case .groupReaded(_, let all):
                    allReaded = all
                }
                cellView.contentContainer.setReadStatus(allReaded: allReaded, title: info.text) { [weak self] in
                    self?.reloadDelegate.didTapRead(messageID: messageID)
                }
            }
            cellView.contentContainer.setPrivateChat(isPrivate: info.isPriavte,
                                                     hasReadTime: info.hasReadTime,
                                                     duration: info.duration) { [self] in // WARNING: There is a strong reference here, so that the delete message function can continue to be executed after it is destroyed after reading.
                reloadDelegate.removeMessage(messageID: messageID)
            }
        }
        
        // MARK: - 张亚飞打的标记  头像显示
        if let avatarView = cellView.containerView.leadingView {
            let avatarViewController = AvatarViewController(user: user, bubble: bubble)
            avatarView.setup(with: avatarViewController)
            avatarViewController.view = avatarView
            
            avatarViewController.onTap = { [weak self] userID in
                self?.gestureDelegate?.didTapAvatar(with: user)
            }
            
            avatarViewController.onLongPress = { [weak self] userID, userName in
                self?.gestureDelegate?.didLongPressAvatar(with: userID, name: userName)
            }
            
//            avatarView.clipsToBounds = true
//            avatarView.layer.cornerRadius = 14
            
            if sessionType == .group {
                if isTop {
                    avatarView.isHidden = false
                } else {
//                    avatarView.isHidden = user.id == lastID
                    avatarView.alpha = user.id == lastID ? 0.00001 : 1
                }
            } else {
                avatarView.isHidden = true
            }
//      avatarView.isHidden = true
        }
        
        if let avatarView = cellView.containerView.trailingView {
            let avatarViewController = AvatarViewController(user: user, bubble: bubble)
            avatarView.setup(with: avatarViewController)
            avatarViewController.view = avatarView
            
            avatarViewController.onTap = { [weak self] userID in
                self?.gestureDelegate?.didTapAvatar(with: user)
            }
            
//            测试修改
            avatarView.isHidden = true
        }

        
    }
    /*
     private func setupSwipeHandlingAccessory(_ cellView: MainContainerView<ChatAvatarView, some Any, StatusView>,
     date: Date,
     accessoryConnectingView: UIView) {
     cellView.accessoryConnectingView = accessoryConnectingView
     cellView.accessoryView.setup(with: DateAccessoryController(date: date))
     cellView.accessorySafeAreaInsets = swipeNotifier.accessorySafeAreaInsets
     cellView.swipeCompletionRate = swipeNotifier.swipeCompletionRate
     swipeNotifier.add(delegate: cellView)
     }
     */
    // Set right slide to display time
    private func setupSwipeHandlingAccessory(_ cellView: MainContainerView<ChatAvatarView, some Any, ChatAvatarView>,
                                             date: Date,
                                             accessoryConnectingView: UIView) {
        cellView.accessoryConnectingView = accessoryConnectingView
        cellView.accessoryView.setup(with: DateAccessoryController(date: date))
        cellView.accessorySafeAreaInsets = swipeNotifier.accessorySafeAreaInsets
        cellView.swipeCompletionRate = swipeNotifier.swipeCompletionRate
        swipeNotifier.add(delegate: cellView)
    }
    
    private func buildFileBubbleController(bubbleView: BezierMaskedView<some Any>,
                                           messageType: MessageType,
                                           bubbleType: Cell.BubbleType) -> BubbleController {
        let textBubbleController = FileBubbleController(bubbleView: bubbleView, type: messageType, bubbleType: bubbleType)
        let bubbleController = BezierBubbleController(bubbleView: bubbleView, controllerProxy: textBubbleController, type: messageType, bubbleType: bubbleType)
        return bubbleController
    }
    
    private func buildReplyBubbleController(bubbleView: BezierMaskedView<some Any>,
                                           messageType: MessageType,
                                           bubbleType: Cell.BubbleType) -> BubbleController {
        let textBubbleController = ReplyBubbleController(bubbleView: bubbleView, type: messageType, bubbleType: bubbleType)
        let bubbleController = BezierBubbleController(bubbleView: bubbleView, controllerProxy: textBubbleController, type: messageType, bubbleType: bubbleType)
        return bubbleController
    }
    
    private func buildBlankBubbleController(bubbleView: BezierMaskedView<some Any>,
                                           messageType: MessageType,
                                           bubbleType: Cell.BubbleType) -> BubbleController {
        let textBubbleController = BlankBubbleController(bubbleView: bubbleView, type: messageType, bubbleType: bubbleType)
        let bubbleController = BezierBubbleController(bubbleView: bubbleView, controllerProxy: textBubbleController, type: messageType, bubbleType: bubbleType)
        return bubbleController
    }
    
    private func buildTextBubbleController(bubbleView: BezierMaskedView<some Any>,
                                           messageType: MessageType,
                                           bubbleType: Cell.BubbleType) -> BubbleController {
        let textBubbleController = TextBubbleController(bubbleView: bubbleView, type: messageType, bubbleType: bubbleType)
        let bubbleController = BezierBubbleController(bubbleView: bubbleView, controllerProxy: textBubbleController, type: messageType, bubbleType: bubbleType)
        return bubbleController
    }
    
    private func buildBezierBubbleController(for bubbleView: BezierMaskedView<some Any>,
                                             messageType: MessageType,
                                             bubbleType: Cell.BubbleType) -> BubbleController {
        let contentBubbleController = FullCellContentBubbleController(bubbleView: bubbleView)
        let bubbleController = BezierBubbleController(bubbleView: bubbleView, controllerProxy: contentBubbleController, type: messageType, bubbleType: bubbleType)
        return bubbleController
    }
}


//测试修改
extension DefaultChatCollectionDataSource: UICollectionViewDataSource {
    
//    func getSystemNotifySection() {
//        for items in sections {
//            items.cells.removeAll{ $0 == .date}
//        }
//    }
    
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        sections[section].cells.count
        if isSystemNotify {
            sections[(sections.count - 1) - section].cells.count
        } else {
            sections[section].cells.count
        }
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        let cell = sections[indexPath.section].cells[indexPath.item]
        
//        var cell : Cell? = nil
//        
//        if isSystemNotify {
//            let cell = sections[(sections.count - 1) - indexPath.section].cells[sections[(sections.count - 1) - indexPath.section].cells.count - 1 - indexPath.item]
//        } else {
//            let cell = sections[indexPath.section].cells[indexPath.item]
//        }
        
        let cell = isSystemNotify ? sections[(sections.count - 1) - indexPath.section].cells[sections[(sections.count - 1) - indexPath.section].cells.count - 1 - indexPath.item] : sections[indexPath.section].cells[indexPath.item]
        
        var lastID: String? = nil
        
        if indexPath.item > 0 {
            let lastCell = sections[indexPath.section].cells[indexPath.item - 1]
            
            switch lastCell {
            case let .message(message, bubbleType: bubbleType):
                lastID = message.owner.id
                break
            default:
                break
            }
        }
        
        
        
        
        
        switch cell {
            
        case let .date(group):
            let cell = createTipsTitle(collectionView: collectionView, indexPath: indexPath, alignment: cell.alignment, title: group.value, enableBackgroundColor: true, needHide: isSystemNotify)
            
            return cell
        case let .systemMessage(group):
            
            let cell = createTipsTitle(collectionView: collectionView, indexPath: indexPath, alignment: cell.alignment, attributeTitle: group.value)
            return cell
            
        case let .messageGroup(group):
            let cell = createGroupTitle(collectionView: collectionView, indexPath: indexPath, alignment: cell.alignment, title: group.title)
            
            return cell
            // MARK: - 张亚飞打的标记  显示消息Cell
        case let .message(message, bubbleType: bubbleType):
            switch message.data {
            case let .text(source):
                if source.type == .text {
                    let cell = createTextCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, text: source.text, anchor: message.isAnchor, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, messageEx: source.ex, isTop: indexPath.item == 0, lastID: lastID)
                    
                    return cell
                } else {
                    let cell = createGroupNoticeCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, source: source, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                    return cell
                }
            case let .attributeText(text):
                let cell = createTextCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, attributedString: text, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                
                return cell
            case let .custom(source):
                // MARK: - 张亚飞打的标记  网站消息Cell
                let cell = createCustomCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, source: source, anchor: message.isAnchor, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                
                return cell
                
            case let .mention(source):
                let cell = createTextCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, attributedString: source.attributedString, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                
                return cell
                
            case let .url(url, isLocallyStored: _):
                if #available(iOS 13.0, *) {
                    return createURLCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, url: url, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                } else {
                    return createTextCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, text: url.absoluteString, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                }
            case let .image(source, isLocallyStored: _):
                let cell = createImageCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, alignment: cell.alignment, user: message.owner, source: source, date: message.date, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                
                return cell
            case let .video(source, isLocallyStored: _):
                let cell = createVideoCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, alignment: cell.alignment, user: message.owner, source: source, date: message.date, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                
                return cell
            case let .audio(source, isLocallyStored: _):
                let cell = createAudioCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, alignment: cell.alignment, user: message.owner, source: source, date: message.date, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                return cell
                
            case let .file(source, isLocallyStored: isLocallyStored):
                let cell = createFileCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, alignment: cell.alignment, user: message.owner, source: source, isLocallyStored: isLocallyStored, date: message.date, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                
                return cell
            case let .quote(source):
                let cell = createReplyCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected,  indexPath: indexPath, source: source, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                
                return cell
            case let .merge(source):
                let cell = createMergeCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, source: source, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                
                return cell
            case let .card(source):
                let cell = createCardCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, source: source, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                
                return cell
            case let .location(source):
                let cell = createLocationCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, source: source, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                
                return cell
            // MARK: - 张亚飞打的标记  通知消息Cell
            case let .notice(source):
//                let cell = createNoticeCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, source: source, date: message.date, alignment: cell.alignment, user: message.owner, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType)
                //测试修改
                let cell = createVipNormalMessage(collectionView: collectionView, indexPath: indexPath, message: message, source: source)
//                let cell = createVipContactMessage(collectionView: collectionView, indexPath: indexPath, alignment: cell.alignment, attributeTitle: nil)
                return cell
            case let .face(source, isLocallyStored: _):
                let cell = createFaceCell(collectionView: collectionView, messageId: message.id, isSelected: message.isSelected, indexPath: indexPath, alignment: cell.alignment, user: message.owner, source: source, date: message.date, bubbleType: bubbleType, status: message.status, messageType: message.type, sessionType: message.sessionType, isTop: indexPath.item == 0, lastID: lastID)
                
                return cell

            }
            
        case .typingIndicator:
            return createTypingIndicatorCell(collectionView: collectionView, indexPath: indexPath)
        default:
            fatalError()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: TextTitleView.reuseIdentifier,
                                                                       for: indexPath) as! TextTitleView
            view.customView.text = sections[indexPath.section].title
            view.customView.preferredMaxLayoutWidth = 300
            view.customView.textColor = .lightGray
            view.customView.numberOfLines = 0
            view.customView.font = .preferredFont(forTextStyle: .caption2)
            return view
        case UICollectionView.elementKindSectionFooter:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: TextTitleView.reuseIdentifier,
                                                                       for: indexPath) as! TextTitleView
            view.customView.text = " "
            return view
        default:
            fatalError()
        }
    }
}

extension DefaultChatCollectionDataSource: ChatLayoutDelegate {
    
    public func shouldPresentHeader(_ chatLayout: CollectionViewChatLayout, at sectionIndex: Int) -> Bool {
        true
    }
    
    public func shouldPresentFooter(_ chatLayout: CollectionViewChatLayout, at sectionIndex: Int) -> Bool {
        true
    }
    
    // MARK: - 张亚飞打的标记  消息的高度
    public func sizeForItem(_ chatLayout: CollectionViewChatLayout, of kind: ItemKind, at indexPath: IndexPath) -> ItemSize {
        switch kind {
        case .cell:
//            let item = sections[indexPath.section].cells[indexPath.item]
            let item = isSystemNotify ? sections[(sections.count - 1) - indexPath.section].cells[sections[(sections.count - 1) - indexPath.section].cells.count - 1 - indexPath.item] : sections[indexPath.section].cells[indexPath.item]
            switch item {
            case let .message(message, bubbleType: _):
                switch message.data {
                case .text, .attributeText, .mention(_), .custom(_), .audio(_):
                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: 50))
                case let .image(_, isLocallyStored: isDownloaded):
                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: isDownloaded ? 120 : 80))
                case let .url(_, isLocallyStored: isDownloaded):
                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: isDownloaded ? 60 : 36))
                case let .video(_, isLocallyStored: isDownloaded):
                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: isDownloaded ? 120 : 80))
                case .file(_, _):
                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: 60))
                case .quote(_), .merge(_), .card(_), .location(_),  .face(_):
                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: 72))
                case .notice(_):
//                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: chatLayout.layoutFrame.height))
                    return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: 110))
                }
//            case .date, .systemMessage:
//                return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: 18))
            case .systemMessage:
                return .estimated(CGSize(width: chatLayout.layoutFrame.width, height: 18))
            case .date:
                return isSystemNotify ? .estimated(CGSize(width: 0, height: 0)) : .estimated(CGSize(width: chatLayout.layoutFrame.width, height: 18))
            case .typingIndicator:
                return .estimated(CGSize(width: 60, height: 36))
            case .messageGroup:
                return .estimated(CGSize(width: min(85, chatLayout.layoutFrame.width / 3), height: 18))
            }
        case .footer, .header:
            return .auto
        }
    }
    
    public func alignmentForItem(_ chatLayout: CollectionViewChatLayout, of kind: ItemKind, at indexPath: IndexPath) -> ChatItemAlignment {
        switch kind {
        case .header:
            return .center
        case .cell:
//            let item = sections[indexPath.section].cells[indexPath.item]
            let item = isSystemNotify ? sections[(sections.count - 1) - indexPath.section].cells[sections[(sections.count - 1) - indexPath.section].cells.count - 1 - indexPath.item] : sections[indexPath.section].cells[indexPath.item]
            switch item {
            case .date, .systemMessage:
                return .center
            case .message:
                return .fullWidth
            case .messageGroup(let msg):
                return msg.type == .incoming ? .leading : .trailing
            case .typingIndicator:
                return .leading
            }
        case .footer:
            return .trailing
        }
    }
    
    public func initialLayoutAttributesForInsertedItem(_ chatLayout: CollectionViewChatLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: ChatLayoutAttributes, on state: InitialAttributesRequestType) {
        originalAttributes.alpha = 0
        guard state == .invalidation,
              kind == .cell else {
            return
        }
//        switch sections[indexPath.section].cells[indexPath.item] {
//        case .typingIndicator:
//            originalAttributes.transform = .init(scaleX: 0.1, y: 0.1)
//            originalAttributes.center.x -= originalAttributes.bounds.width / 5
//        default:
//            break
//        }
        
        
        switch isSystemNotify ? sections[(sections.count - 1) - indexPath.section].cells[sections[(sections.count - 1) - indexPath.section].cells.count - 1 - indexPath.item] : sections[indexPath.section].cells[indexPath.item] {
        case .typingIndicator:
            originalAttributes.transform = .init(scaleX: 0.1, y: 0.1)
            originalAttributes.center.x -= originalAttributes.bounds.width / 5
        default:
            break
        }
    }
    
    public func finalLayoutAttributesForDeletedItem(_ chatLayout: CollectionViewChatLayout, of kind: ItemKind, at indexPath: IndexPath, modifying originalAttributes: ChatLayoutAttributes) {
        originalAttributes.alpha = 0
        guard kind == .cell else {
            return
        }
        
        switch isSystemNotify ? oldSections[(oldSections.count - 1) - indexPath.section].cells[oldSections[(oldSections.count - 1) - indexPath.section].cells.count - 1 - indexPath.item] : oldSections[indexPath.section].cells[indexPath.item] {
        case .typingIndicator:
            originalAttributes.transform = .init(scaleX: 0.1, y: 0.1)
            originalAttributes.center.x -= originalAttributes.bounds.width / 5
        default:
            break
        }
        
//        switch oldSections[indexPath.section].cells[indexPath.item] {
//        case .typingIndicator:
//            originalAttributes.transform = .init(scaleX: 0.1, y: 0.1)
//            originalAttributes.center.x -= originalAttributes.bounds.width / 5
//        default:
//            break
//        }
    }
}
