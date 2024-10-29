
import ChatLayout
import DifferenceKit
import Foundation
import InputBarAccessoryView
import UIKit
import OUICore
import OUICoreView
import ProgressHUD
import MJRefresh

#if ENABLE_CALL
import OUICalling
#endif

#if ENABLE_LIVE_ROOM
import OUILive
#endif

extension Notification.Name {
    static let clearRecord = Notification.Name("chat.clear.record")
}

// MARK: - 张亚飞打的标记  聊天界面

final class ChatViewController: UIViewController {
    
    private var toolItems: [ToolItem] = ToolItem.allCases
    
    private enum ToolItem: CaseIterable {
        case copy
        case delete
        case forward
        case reply
        case revoke
        case muiltSelection
        case translate
        case star
        
        var image: UIImage? {
            switch self {
            case .copy:
                return UIImage(nameInBundle: "chat_tool_copy_btn_icon")
            case .delete:
                return UIImage(nameInBundle: "chat_tool_delete_btn_icon")
            case .forward:
                return UIImage(nameInBundle: "chat_tool_forward_btn_icon")
            case .reply:
                return UIImage(nameInBundle: "chat_tool_reply_btn_icon")
            case .revoke:
                return UIImage(nameInBundle: "chat_tool_revoke_btn_icon")
            case .muiltSelection:
                return UIImage(nameInBundle: "chat_tool_multi_sel_btn_icon")
            case .translate:
                return UIImage(nameInBundle: "chat_tool_translate_btn_icon")
            case .star:
                return UIImage(named: "chat_tool_translate_btn_star")
            }
        }
        
        var title: String {
            switch self {
            case .copy:
                return "复制".innerLocalized()
            case .delete:
                return "删除".innerLocalized()
            case .forward:
                return "转发".innerLocalized()
            case .reply:
                return "回复".innerLocalized()
            case .revoke:
                return "撤回".innerLocalized()
            case .muiltSelection:
                return "多选".innerLocalized()
            case .translate:
                return "翻译".innerLocalized()
            case .star:
                return "收藏".localized()
            }
        }
    }
    
    private enum ReactionTypes {
        case delayedUpdate
    }
    
    private var ignoreInterfaceActions = true
    
    private enum InterfaceActions {
        case changingKeyboardFrame
        case changingContentInsets
        case changingFrameSize
        case sendingMessage
        case scrollingToTop
        case scrollingToBottom
        case showingPreview
        case showingAccessory
        case updatingCollectionInIsolation
    }
    
    private enum ControllerActions {
        case loadingInitialMessages
        case loadingPreviousMessages
        case loadingMoreMessages
        case updatingCollection
    }
    
    private lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let v = AutocompleteManager(for: inputBarView.inputTextView)
        v.delegate = self
        v.register(
            prefix: "@",
            with: [
                .font: UIFont.f17,
                .foregroundColor: UIColor.systemBlue,
                .backgroundColor: UIColor.systemBlue.withAlphaComponent(0.3),
            ])
        
        return v
    }()
    
    private var hashtagAutocompletes: [AutocompleteCompletion] = {
        var array: [AutocompleteCompletion] = []
        for i in 1 ... 100 {
            array.append(AutocompleteCompletion(text: "tag + \(i)", context: nil))
        }
        return array
    }()
    
    private var mentionCompletions: [AutocompleteCompletion] = []
    private var renderingMentionText: Bool = false
    
    private var currentInterfaceActions: SetActor<Set<InterfaceActions>, ReactionTypes> = SetActor()
    private var currentControllerActions: SetActor<Set<ControllerActions>, ReactionTypes> = SetActor()
    private let editNotifier: EditNotifier
    private let swipeNotifier: SwipeNotifier
//    private var collectionView: UICollectionView!
    public var collectionView: UICollectionView!
    private var chatLayout = CollectionViewChatLayout()
    private let inputBarView = CoustomInputBarAccessoryView()
    
    private var editBottomView: EditingBottomView?
    private var oldLeftBarButtonItem: UIBarButtonItem?
    
    
    private let chatController: ChatController
    private let dataSource: ChatCollectionDataSource
    private var animator: ManualAnimator?
    
    private var translationX: CGFloat = 0
    private var currentOffset: CGFloat = 0
    private var lastContentOffset: CGFloat = 0
    
    private var hiddenInputBar: Bool = false
    private var scrollToTop: Bool = false
    
    private var titleView = ChatTitleView()
    private var bottomTipsView: EditingBottomTipsView?
    private var inputBarViewBottomAnchor: NSLayoutConstraint!
    
    private var documentInteractionController: UIDocumentInteractionController!
    
    private var otherIsInBlacklist = false
    
    private var keepContentOffsetAtBottom = true {
        didSet {
            chatLayout.keepContentOffsetAtBottomOnBatchUpdates = keepContentOffsetAtBottom
        }
    }
    
    private var popover: PopoverCollectionViewController?
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleRevealPan(_:)))
        gesture.delegate = self
        
        return gesture
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        gesture.delegate = self
        
        return gesture
    }()
    
    lazy var settingButton: UIBarButtonItem = {
        let v = UIBarButtonItem(image: UIImage(nameInBundle: "common_more_btn_icon"), style: .done, target: self, action: #selector(settingButtonAction))
        v.tintColor = .black
        v.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)

        return v
    }()
    
    // MARK: - 张亚飞打的标记  聊天界面右上角弹窗
    @objc
    private func settingButtonAction() {
        popover?.dismiss()
        
        
        let conversation = self.chatController.getConversation()
        let conversationType = conversation.conversationType
        switch conversationType {
        case .undefine:
            break
        case .notification:
            print("系统通知设置")
            print(chatController.getConversation().conversationID)
//            chatController.getOtherInfo { [weak self] others in
//                guard let self else { return }
                if let handler = OIMApi.gotoSystemSettingHandle {
                    
                    self.view.endEditing(true)
                    handler(self, chatController.getConversation().conversationID, { res in
                       
                    })
                }
//            }
            break
        case .c2c:
            
//                let viewModel = SingleChatSettingViewModel(conversation: conversation, userInfo: UserInfo(userID: others.userID!, nickname: others.showName, faceURL: others.faceURL))
//                let vc = SingleChatSettingTableViewController(viewModel: viewModel, style: .grouped)
//                self.navigationController?.pushViewController(vc, animated: true)
            
//               ((_ currentVC: UIViewController, _  userID: String, _ nickname: String, _ faceURL: String ,_ completion: @escaping ((String) -> Void)) -> Void)
            chatController.getOtherInfo { [weak self] others in
                guard let self else { return }
                if let handler = OIMApi.showChatVCShoeethandle {
                    self.resetOffset(newBottomInset: 0, duration: 0)
                    self.view.endEditing(true)
                    handler(self, others.userID!, { res in
                        if res == "reload" {
                            self.collectionView.reloadData()
                            self.scrollToBottom()
                        }
                    })
                }
                
            }
            
            
        case .superGroup:
            chatController.getGroupInfo(force: false) { [weak self] info in
                guard let self else { return }
                
                let vc = GroupChatSettingTableViewController(conversation: conversation, groupInfo: info, style: .grouped)
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    lazy var mediaButton: UIBarButtonItem = {
        let v = UIBarButtonItem(image: UIImage(nameInBundle: "chat_call_btn_icon"), style: .done, target: self, action: #selector(mediaButtonAction))
        v.tintColor = .black
        v.imageInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)

        return v
    }()
    
    @objc
    private func mediaButtonAction() {
        popover?.dismiss()
        
        showMediaLinkSheet()
    }
    
    private lazy var inMeetingView: InMeetingView = {
        let v = InMeetingView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        
        v.joinHandler = { [weak self] in
            self?.chatController.joinMeetingMidway(isVedio: v.isVideo)
        }
        return v
    }()
    
    private lazy var noticeView: GroupNoticeView = {
        let v = GroupNoticeView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        
        v.onClose = {
            v.isHidden = true
        }
        
        return v
    }()
    
    private let loadMoreView = UIActivityIndicatorView()
    
    private let watermarkView: WatermarkBackgroundView = {
        let v = WatermarkBackgroundView()
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    init(chatController: ChatController,
         dataSource: ChatCollectionDataSource,
         editNotifier: EditNotifier,
         swipeNotifier: SwipeNotifier,
         hiddenInputBar: Bool = false,
         scrollToTop: Bool = false) {
        self.chatController = chatController
        self.dataSource = dataSource
        self.editNotifier = editNotifier
        self.swipeNotifier = swipeNotifier
        self.hiddenInputBar = hiddenInputBar
        self.scrollToTop = scrollToTop
//        self.scrollToTop = true
        super.init(nibName: nil, bundle: nil)
        
//        if  self.chatController.getConversation().conversationType == .notification {
//            self.dataSource.
//        }
        
        
        loadInitialMessages()
        reloadCollectionview()
    }
    
    @available(*, unavailable, message: "Use init(messageController:) instead")
    override convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }
    
    @available(*, unavailable, message: "Use init(messageController:) instead")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("\(type(of: self)) - \(#function)")
    }
    
    // MARK: - 张亚飞打的标记  自定义 nav
    lazy var chatViewControllerNav: ChatViewControllerNav = {
        let r = ChatViewControllerNav()
        let info = chatController.getConversation()
        let conversation = self.chatController.getConversation()
        r.backBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        r.gotoUserBlock = { [weak self] in
            if let handler = OIMApi.gotoUserMessageHandle {
                handler(self!, String(info.userID!), "", "",{res in

                })
            }
        }
        r.gotoGroupBlock = { [weak self] in
            self?.chatController.getGroupInfo(force: false) { [weak self] info in
                guard let self else { return }
                
                let vc = GroupChatSettingTableViewController(conversation: conversation, groupInfo: info, style: .grouped)
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
        r.showMoreBlock = { [weak self] in
            self?.settingButtonAction()
        }
        r.gotoGroupUserListBlock = { [weak self] in
            self?.chatController.getGroupInfo(force: false) { [weak self] info in
                guard let self else { return }
                
                let vc = MemberListViewController(viewModel: MemberListViewModel(groupInfo: info))
                            navigationController?.pushViewController(vc, animated: false)
            }
        }
        return r
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chatController.getConversation().conversationType == .notification  {
            scrollToTop = true
        }
        
//        if #available(iOS 13.0, *) {
//            view.backgroundColor = .systemBackground
//        } else {
//            view.backgroundColor = .white
//        }
//        view.backgroundColor = .init(hexString: "#f5f5f5")
//        setupNavigationBar()
        view.backgroundColor = .white
        updateChatNavData()
        setupWatermarkView()
        setupInputBar()
        updateUnreadCount(count: 0)
        
        chatLayout.settings.interItemSpacing = 10
        chatLayout.settings.interSectionSpacing = 4
        chatLayout.settings.additionalInsets = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
       
            chatLayout.keepContentOffsetAtBottomOnBatchUpdates = !scrollToTop
        
        
        chatLayout.processOnlyVisibleItemsOnAnimatedBatchUpdates = false
        
        collectionView = UICollectionView(frame: view.frame, collectionViewLayout: chatLayout)
//        view.addSubview(collectionView)
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = dataSource
        chatLayout.delegate = dataSource
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .interactive
//        collectionView.decelerationRate = .fast
        
        /// https://openradar.appspot.com/40926834
        collectionView.isPrefetchingEnabled = false
        
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.automaticallyAdjustsScrollIndicatorInsets = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        dataSource.prepare(with: collectionView)
        
        setupRefreshControl()
        
        inputBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBarView)
        
        let vStack = UIStackView(arrangedSubviews: [noticeView, inMeetingView, collectionView])
        vStack.axis = .vertical
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(chatViewControllerNav)
        view.addSubview(vStack)
        
        chatViewControllerNav.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(44 + kStatusBarHeight)
        }
        
        NSLayoutConstraint.activate([
//            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 44 + kStatusBarHeight),
            vStack.bottomAnchor.constraint(equalTo: hiddenInputBar ? view.bottomAnchor : inputBarView.topAnchor, constant: 0),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            
            inputBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        inputBarViewBottomAnchor = inputBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        inputBarViewBottomAnchor.isActive = true
        
        KeyboardListener.shared.add(delegate: self)
        //        collectionView.addGestureRecognizer(panGesture)
        collectionView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadInitialMessages), name: Notification.Name.clearRecord, object: nil)
    }
    
    //测试修改  单聊nav
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        setWartermarkBackground()
        getDraft()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.invalidateLayout()
        navigationController?.navigationBar.isHidden = true
        if var draft = chatController.getConversation().draftText, !draft.isEmpty {
            inputBarView.inputTextView.becomeFirstResponder()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setDraft()
        
        IMController.shared.imManager.markConversationMessage(asRead: chatController.getConversation().conversationID) { res in
            
            print(res)
        } onFailure: { code, res in
            print(res)
        }
        
//        navigationController?.navigationBar.isHidden = false
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard isViewLoaded else {
            return
        }
        currentInterfaceActions.options.insert(.changingFrameSize)
        let positionSnapshot = chatLayout.getContentOffsetSnapshot(from: .bottom)
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setNeedsLayout()
        coordinator.animate(alongsideTransition: { _ in
            // Gives nicer transition behaviour
            // self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.performBatchUpdates(nil)
        }, completion: { _ in
            if let positionSnapshot,
               !self.isUserInitiatedScrolling {
                // As contentInsets may change when size transition has already started. For example, `UINavigationBar` height may change
                // to compact and back. `CollectionViewChatLayout` may not properly predict the final position of the element. So we try
                // to restore it after the rotation manually.
                self.chatLayout.restoreContentOffset(with: positionSnapshot)
            }
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.currentInterfaceActions.options.remove(.changingFrameSize)
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        swipeNotifier.setAccessoryOffset(UIEdgeInsets(top: view.safeAreaInsets.top,
                                                      left: view.safeAreaInsets.left + chatLayout.settings.additionalInsets.left,
                                                      bottom: view.safeAreaInsets.bottom,
                                                      right: view.safeAreaInsets.right + chatLayout.settings.additionalInsets.right))
    }
    
    //    // Apple doesnt return sometimes inputBarView back to the app. This is an attempt to fix that
    //    // See: https://github.com/ekazaev/ChatLayout/issues/24
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if inputBarView.superview == nil,
           topMostViewController() is ChatViewController {
            DispatchQueue.main.async { [weak self] in
                self?.reloadInputViews()
            }
        }
    }
    
    @objc
    private func loadInitialMessages() {
        guard !currentControllerActions.options.contains(.loadingInitialMessages) else { return }
        
        currentControllerActions.options.insert(.loadingInitialMessages)
        chatController.loadInitialMessages { [weak self] sections in
            self?.processUpdates(with: sections, animated: false, requiresIsolatedProcess: true) {
                self?.currentControllerActions.options.remove(.loadingInitialMessages)
                self?.ignoreInterfaceActions = false
            }
        }
    }
    
    func reloadCollectionview() {
        OIMApi.reloadCollectionView = {[weak self] res in
//            print("更新")
//            self?.collectionView.reloadData()
        }
  
    }
    
    
    
    
    // MARK: - 张亚飞打的标记  聊天页面nav上的按钮
    private func setRightButtons(show: Bool) {
        if show {
#if ENABLE_CALL
            navigationItem.rightBarButtonItems = [settingButton, mediaButton]
#else
            navigationItem.rightBarButtonItems = [settingButton]
#endif
        } else {
            navigationItem.rightBarButtonItems = nil
        }
    }
    
    private func setupNavigationBar() {
        chatController.getTitle()
        navigationItem.titleView = titleView
        
        
        
        if let navigationBar = navigationController?.navigationBar {
            let underline = UIView()
            underline.backgroundColor = .cE8EAEF
            underline.translatesAutoresizingMaskIntoConstraints = false
            
            navigationBar.addSubview(underline)
            NSLayoutConstraint.activate([
                underline.heightAnchor.constraint(equalToConstant: 1),
                underline.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
                underline.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),
                underline.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor)
            ])
        }
        
        if  chatController.getConversation().conversationType == .notification {
            print("系统通知")
            let info = chatController.getConversation()
            titleView.mainLabel.text = info.showName
            view.backgroundColor = .init(hexString: "#f5f5f5")
            navigationItem.rightBarButtonItems = [settingButton]
            
            
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
//            [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:true];
            
//            let indexPath = IndexPath(row: 1, section: 0)
//            collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
            
        }
    }
    
    
    //自定义nav
    func updateChatNavData() {
        
        chatViewControllerNav.updateAbout(info: chatController.getConversation())
        
        if chatController.getConversation().conversationType == .notification {
            view.backgroundColor = .init(hexString: "#f5f5f5")
//            tableViewAddEmptyView()
        }
        
        self.chatController.getGroupInfo(force: false) { [weak self] info in
            guard let self else { return }
            
//            chatViewControllerNav.GroupTitleLbl.text = "\(info.groupName)(\(info.memberCount))"
        }
    }
    
    
    
    func tableViewAddEmptyView() {
        let emptyV:HDEmptyView = HDEmptyView.emptyActionViewWithImageStr(imageStr: "custom_blank_icon", titleStr: "空空如也".localized() as NSString, detailStr: "", btnTitleStr: "", target: self, action: #selector(reloadBtnAction)) as! HDEmptyView
        
//        emptyV.titleLabTextColor = UIColor.red
//        emptyV.actionBtnFont = UIFont.systemFont(ofSize: 19)
//        emptyV.contentViewY = -90
//        emptyV.actionButton.isHidden = true
//        emptyV.titleLabFont = UIFont(name: "PingFangSC-Medium", size: 16)!
//        emptyV.titleLabTextColor =  UIColor.init(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        collectionView.ly_emptyView = emptyV
    }
        
    @objc func reloadBtnAction() {
        
    }
    
    
    
    
    
    
    private func setupWatermarkView() {
        view.insertSubview(watermarkView, at: 0)
        
        NSLayoutConstraint.activate([
            watermarkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            watermarkView.topAnchor.constraint(equalTo: view.topAnchor),
            watermarkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            watermarkView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setWartermarkBackground() {
        DispatchQueue.global().async { [self] in
            let path = FileHelper.shared.exsit(path: "", name: "chat_bg_\(chatController.getConversation().conversationID).png")
            if let path, let image = UIImage(contentsOfFile: path) {
                DispatchQueue.main.async { [self] in
                    watermarkView.imageView.image = image
                }
            } else {
                DispatchQueue.main.async { [self] in
                    watermarkView.imageView.image = nil
                }
            }
        }
        
#if ENABLE_ORGANIZATION
        watermarkView.text = chatController.getSelfInfo()?.nickname
#endif
    }

    private func setupInputBar() {
        inputBarView.delegate = self
        inputBarView.shouldAnimateTextDidChangeLayout = true
        inputBarView.maxTextViewHeight = 120.h
        // Set plugins
        inputBarView.inputPlugins.append(autocompleteManager)
        
        if let userID = chatController.getSelfInfo()?.userID {
            inputBarView.identity = userID
        }
        inputBarView.isHidden = hiddenInputBar
    }
    
    private func setupRefreshControl() {
        
        if chatController.getConversation().conversationType == .notification  {
            
            let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(handleRefresh))
            footer.stateLabel?.isHidden = true
            collectionView.mj_footer = footer
        } else {
            let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(handleRefresh))
            header.stateLabel?.isHidden = true
            header.lastUpdatedTimeLabel?.isHidden = true
            collectionView.mj_header = header
        }
        
       
        
        
    }
    
    @objc private func handleRefresh() {
        if !currentControllerActions.options.contains(.loadingPreviousMessages) {
            currentControllerActions.options.insert(.loadingPreviousMessages)
        }
//        chatLayout.keepContentOffsetAtBottomOnBatchUpdates = false
        chatController.loadPreviousMessages { [weak self] sections in
            guard let self else {
                return
            }
            // Reloading the content without animation just because it looks better is the scrolling is in process.
            let animated = !self.isUserInitiatedScrolling
            self.processUpdates(with: sections, animated: false, requiresIsolatedProcess: false) {
                self.collectionView.mj_header?.endRefreshing()
                self.collectionView.mj_footer?.endRefreshing()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    self.currentControllerActions.options.remove(.loadingPreviousMessages)
                }
            }
        }
    }
    
    @objc private func setEditNotEdit(forceEnd: Bool = false) {
        if forceEnd {
            isEditing = false
        } else {
            isEditing = !isEditing
        }
        editNotifier.setIsEditing(isEditing, duration: .animated(duration: 0.25))
        chatLayout.invalidateLayout()
        
        if !isEditing {
            showEditBottomView(show: false)
            chatController.defaultSelecteMessage(with: nil, onlySelect: false)
        }
    }
    
    // Editing status, display the delete and forward buttons below
    private func showEditBottomView(show: Bool = true, messageID: String? = nil) {
        if show {
            oldLeftBarButtonItem = navigationItem.leftBarButtonItem
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消".innerLocalized(), style: .done, target: self, action: #selector(setEditNotEdit))
//            chatController.defaultSelecteMessage(with: messageID!)
            
            inputBarView.inputTextView.resignFirstResponder()
            let bottomController = EditingBottomController()
            editBottomView = EditingBottomView(controller: bottomController)
            bottomController.delegate = self
            view.addSubview(editBottomView!)
            NSLayoutConstraint.activate([
                editBottomView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                editBottomView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                editBottomView!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
            inputBarView.isHidden = true
        } else {
            navigationItem.leftBarButtonItem = oldLeftBarButtonItem
            inputBarView.isHidden = false
            editBottomView?.removeFromSuperview()
        }
    }
    
    private func revokeMessage(with id: String, completion: @escaping () -> Void) {
        self.chatController.revokeMessage(with: id, completion: completion)
    }
    
    // 音视频
    private func showMediaLinkSheet() {
        // (#330)
        resetOffset(newBottomInset: 0)
        inputBarView.inputResignFirstResponder()
#if ENABLE_LIVE_ROOM
        if CallingManager.isBusy || LiveRoomViewController.isBusy {
            presentAlert(title: "callingBusy".innerLocalized())
            
            return
        }
#else
        if custom.isBusy {
            presentAlert(title: "callingBusy".innerLocalized())
            
            return
        }
#endif
        presentMediaActionSheet { [weak self] in
            guard let self else { return }
            
            if otherIsInBlacklist {
                presentAlert(title: "otherIsInblacklistHit".innerLocalizedFormat(arguments: "voice".innerLocalized()), cancelTitle: "iSee".innerLocalized())
            } else {
                startMedia(isVideo: false)
            }
        } videoHandler: { [weak self] in
            guard let self else { return }
            
            if otherIsInBlacklist {
                presentAlert(title: "otherIsInblacklistHit".innerLocalizedFormat(arguments: "video".innerLocalized()), cancelTitle: "iSee".innerLocalized())
            } else {
                startMedia(isVideo: true)
            }
        }
    }
    
    // MARK: - 张亚飞打的标记  音视频
    private func chooseVoiceORVideo(isVideo: Bool) {
        popover?.dismiss()
        // (#330)
        resetOffset(newBottomInset: 0)
        inputBarView.inputResignFirstResponder()
#if ENABLE_LIVE_ROOM
        if CallingManager.isBusy || LiveRoomViewController.isBusy {
            presentAlert(title: "callingBusy".innerLocalized())
            
            return
        }
#else
        if CallingManager.isBusy {
            presentAlert(title: "callingBusy".innerLocalized())
            
            return
        }
#endif
        if isVideo {
            if otherIsInBlacklist {
                presentAlert(title: "otherIsInblacklistHit".innerLocalizedFormat(arguments: "video".innerLocalized()), cancelTitle: "iSee".innerLocalized())
            } else {
                startMedia(isVideo: true)
            }
        } else {
            if otherIsInBlacklist {
                presentAlert(title: "otherIsInblacklistHit".innerLocalizedFormat(arguments: "voice".innerLocalized()), cancelTitle: "iSee".innerLocalized())
            } else {
                startMedia(isVideo: false)
            }
        }

    }
    
    
    // MARK: - 张亚飞打的标记  音视频通话
    // 音视频通话
    private func startMedia(isVideo: Bool) {
        guard mediaButton.isEnabled else { return }
        
        // (#330)
        resetOffset(newBottomInset: 0)
#if ENABLE_CALL
        let conversation = chatController.getConversation()
        if conversation.groupID?.isEmpty == false {
            let membersVC = SelectContactsViewController(types: [.members], sourceID: conversation.groupID, allowsMultipleSelection: true)
            membersVC.selectedContact(hasSelected: []) { [weak self] _, r in
                
                self?.navigationController?.popViewController(animated: false)
                
                let ms = r.map {CallingUserInfo(userID: $0.ID, nickname: $0.name, faceURL: $0.faceURL)}
                let me = self?.chatController.getSelfInfo()
                let inviter = CallingUserInfo(userID: me?.userID, nickname: me?.nickname, faceURL: me?.faceURL)
                
                CallingManager.manager.startLiveChat(inviter: inviter,
                                                     others: ms,
                                                      isVideo: isVideo,
                                                      groupID: conversation.groupID)
            }
            
            navigationController?.pushViewController(membersVC, animated: true)
        } else {
            let user = CallingUserInfo(userID: conversation.userID!, nickname: conversation.showName, faceURL: conversation.faceURL)
            let me = chatController.getSelfInfo()
            let inviter = CallingUserInfo(userID: me?.userID, nickname: me?.nickname, faceURL: me?.faceURL)
            
            CallingManager.manager.startLiveChat(inviter: inviter,
                                                 others: [user],
                                                 isVideo: isVideo)
        }
#endif
    }
    
    // 显示中途加入会议
    private func showInMeetingView(show: Bool = true, isVideo: Bool = true, members: [GroupMemberInfo] = []) {
        if show {
            inMeetingView.isVideo = isVideo
            inMeetingView.members = members
            inMeetingView.isHidden = false
        } else {
            inMeetingView.isHidden = true
        }
    }
    
    // Display group announcements once.
    private func showGroupAnnouncements(groupInfo: GroupInfo) {
        guard let n = groupInfo.notification, !n.isEmpty else { return }
        
        let onceKey = "com.show.group.announcements.once"
        var announcement: String?
        var announcements = UserDefaults.standard.object(forKey: onceKey) as? [String: String]
        
        if let announcements {
            announcement = announcements[chatController.getConversation().conversationID];
        } else {
            announcements = [:]
        }
        
        guard announcement == nil || announcement != n else { return }
        
        announcements?[chatController.getConversation().conversationID] = n
        UserDefaults.standard.setValue(announcements, forKey: onceKey)
        UserDefaults.standard.synchronize()
        
        noticeView.contentLabel.text = n
        noticeView.isHidden = false
        
        noticeView.onTap = { [weak self, groupInfo] in
            guard let self else { return }
            
            noticeView.isHidden = true
            let vc = GroupAnnounceViewController(groupInfo: groupInfo)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func setDraft() {
        let mentionDraftKey = "mentionDraftKey-\(chatController.getConversation().conversationID)"
        var tempText = inputBarView.inputTextView.text
        
        if !mentionCompletions.isEmpty {
            mentionCompletions.forEach { completion in
                if let userID = completion.context?["id"] as? String {
                    let name = completion.text
                    tempText = tempText?.replacingOccurrences(of: "@\(name)", with: "@\(userID)")
                }
            }
            
            UserDefaults.standard.setValue(tempText, forKey: mentionDraftKey)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.removeObject(forKey: mentionDraftKey)
            UserDefaults.standard.synchronize()
        }
        
        chatController.saveDraft(text: inputBarView.inputTextView.text)
    }
    
    private func getDraft() {
        let mentionDraftKey = "mentionDraftKey-\(chatController.getConversation().conversationID)"
        
        if var draft = chatController.getConversation().draftText, !draft.isEmpty {
            let mentionDraft = UserDefaults.standard.string(forKey: mentionDraftKey)
            
            if let mentionDraft {
                renderingMentionText = true
                setMentionText(mentionText: mentionDraft) { [weak self] in
                    self?.renderingMentionText = false
                }
            } else {
                inputBarView.inputTextView.text = draft
            }
        }
    }
    
    private func setMentionText(mentionText: String, completion: (() -> Void)? = nil) {
        DispatchQueue.global().async { [self] in
            
            let mentionAll = chatController.getMentionAllFlag()
            var tempText = mentionText
            
            var userIDs: [String] = []
            var ranges: [NSRange] = []
            let pattern = "@(\\d+|\(mentionAll.tag)) "
            
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let matches = regex.matches(in: mentionText, options: [], range: NSRange(location: 0, length: mentionText.utf16.count))
                
                for match in matches {
                    if match.numberOfRanges > 1 {
                        let range = match.range(at: 1)
                        if let swiftRange = Range(range, in: mentionText) {
                            let mention = String(mentionText[swiftRange])
                            print("Found numeric mention: \(mention)")
                            userIDs.append(mention)
                        }
                        
                        ranges.append(match.range)
                    }
                }
            }
                        
            chatController.getGroupMembers(userIDs: userIDs, memory: false) { [weak self] infos in
                DispatchQueue.global().async { [self] in
                    guard let self else { return }
                    
                    var tempMembers = infos
                    
                    if let index = userIDs.firstIndex(of: mentionAll.tag) {
                        let fakeMember = GroupMemberInfo()
                        fakeMember.userID = mentionAll.tag
                        fakeMember.nickname = mentionAll.text
                        tempMembers.insert(fakeMember, at: index)
                    }
                    
                    let userInofs = tempMembers.filter({ userIDs.contains($0.userID!) })
                    let failUsers = tempMembers.filter({ !userIDs.contains($0.userID!) }).compactMap({ $0.userID })
                    failUsers.map({ tempText.replace($0, withString: "") })
                    userInofs.map({ tempText.replace($0.userID!, withString: $0.nickname ?? "") })
                    
                    DispatchQueue.main.async { [self] in
                        autocompleteManager.textView?.attributedText = NSAttributedString(string: tempText, attributes: autocompleteManager.defaultTextAttributes)
                        
                        for (_, userInfo) in userInofs.enumerated() {
                            let nickname = userInfo.nickname ?? ""
                            
                            let com = AutocompleteCompletion(text: nickname, context: ["id": userInfo.userID!])
                            autocompleteManager.replaceCompletion(target: "@\(nickname) ", with: com)
                            
                            mentionCompletions.append(com)
                        }
                        
                        completion?()
                    }
                }
            }
        }
    }
}

extension ChatViewController: UIScrollViewDelegate {
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        guard scrollView.contentSize.height > 0,
              !currentInterfaceActions.options.contains(.showingAccessory),
              !currentInterfaceActions.options.contains(.showingPreview),
              !currentInterfaceActions.options.contains(.scrollingToTop),
              !currentInterfaceActions.options.contains(.scrollingToBottom) else {
            return false
        }
        // Blocking the call of loadPreviousMessages() as UIScrollView behaves the way that it will scroll to the top even if we keep adding
        // content there and keep changing the content offset until it actually reaches the top. So instead we wait until it reaches the top and initiate
        // the loading after.
        currentInterfaceActions.options.insert(.scrollingToTop)
        return true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        guard !currentControllerActions.options.contains(.loadingInitialMessages),
              !currentControllerActions.options.contains(.loadingPreviousMessages) else {
            return
        }
        currentInterfaceActions.options.remove(.scrollingToTop)
        loadPreviousMessages()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        popover?.dismiss()
        
        if collectionView.isTracking {
            let bottomInset = scrollView.contentInset.bottom
            
            if scrollView.contentOffset.y < lastContentOffset && scrollView.contentOffset.y > -bottomInset {
                // User is scrolling down
                let scrollViewHeight = scrollView.frame.height
                let contentHeight = scrollView.contentSize.height
                
                if scrollView.contentOffset.y + scrollViewHeight < contentHeight {
                    // Exclude the case when scrolling down at the bottom
                    // User is scrolling down
                    if inputBarView.inputTextView.isFirstResponder {
                        inputBarView.inputTextView.resignFirstResponder()
                        resetOffset(newBottomInset: 0)
                    }
                }
            }
        }
        
        lastContentOffset = scrollView.contentOffset.y

//        print("====\(#function) - contentOffset:\(scrollView.contentOffset) - contentSize:\(scrollView.contentSize)")
        if currentControllerActions.options.contains(.updatingCollection), collectionView.isDragging {
            // Interrupting current update animation if user starts to scroll while batchUpdate is performed. It helps to
            // avoid presenting blank area if user scrolls out of the animation rendering area.
            UIView.performWithoutAnimation {
                self.collectionView.performBatchUpdates({}, completion: { _ in
                    let context = ChatLayoutInvalidationContext()
                    context.invalidateLayoutMetrics = false
                    self.collectionView.collectionViewLayout.invalidateLayout(with: context)
                })
            }
        }
        guard !currentControllerActions.options.contains(.loadingInitialMessages),
              !currentControllerActions.options.contains(.loadingPreviousMessages),
              !currentControllerActions.options.contains(.loadingMoreMessages),
              !currentInterfaceActions.options.contains(.scrollingToTop),
              !currentInterfaceActions.options.contains(.scrollingToBottom) else {
            return
        }
        
        if scrollView.contentOffset.y <= -(scrollView.adjustedContentInset.top + 40) {
            currentControllerActions.options.insert(.loadingPreviousMessages)
            chatLayout.keepContentOffsetAtBottomOnBatchUpdates = true
//            loadPreviousMessages()
        } else {
            if !currentControllerActions.options.contains(.loadingPreviousMessages), !keepContentOffsetAtBottom {
                chatLayout.keepContentOffsetAtBottomOnBatchUpdates = collctionViewIsAtBottom
            }
            
            let contentOffsetY = scrollView.contentOffset.y

            let contentSizeH = scrollView.contentSize.height
            let scrollViewBoundsH = scrollView.bounds.size.height
            let footerViewY = max(contentSizeH, scrollViewBoundsH) + scrollView.contentInset.bottom
            
            let footerViewFullApperance = contentOffsetY + scrollViewBoundsH
            let isCanRefreshing = footerViewFullApperance - footerViewY - 50 > 0
            
            if scrollView.isDragging, isCanRefreshing {
                loadMoreMessages()
            }
        }
    }
    
    private func loadPreviousMessages() {
        // Blocking the potential multiple call of that function as during the content invalidation the contentOffset of the UICollectionView can change
        // in any way so it may trigger another call of that function and lead to unexpected behaviour/animation
        currentControllerActions.options.insert(.loadingPreviousMessages)
        chatController.loadPreviousMessages { [weak self] sections in
            guard let self else {
                return
            }
            // Reloading the content without animation just because it looks better is the scrolling is in process.
            let animated = !self.isUserInitiatedScrolling
            self.processUpdates(with: sections, animated: false, requiresIsolatedProcess: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    self.currentControllerActions.options.remove(.loadingPreviousMessages)
                }
            }
        }
    }
    
    private func loadMoreMessages() {
        // Blocking the potential multiple call of that function as during the content invalidation the contentOffset of the UICollectionView can change
        // in any way so it may trigger another call of that function and lead to unexpected behaviour/animation
        currentControllerActions.options.insert(.loadingMoreMessages)
        chatController.loadMoreMessages { [weak self] sections in
            guard let self else {
                return
            }
            // Reloading the content without animation just because it looks better is the scrolling is in process.
            let animated = !self.isUserInitiatedScrolling
            self.processUpdates(with: sections, animated: false, requiresIsolatedProcess: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                    self.currentControllerActions.options.remove(.loadingMoreMessages)
                }
            }
        }
    }
    
    fileprivate var isUserInitiatedScrolling: Bool {
        collectionView.isDragging || collectionView.isDecelerating
    }
    
    private var collctionViewIsAtBottom: Bool {
        let contentOffsetAtBottom = CGPoint(x: collectionView.contentOffset.x,
                                            y: chatLayout.collectionViewContentSize.height - collectionView.frame.height + collectionView.adjustedContentInset.bottom)
        
        return contentOffsetAtBottom.y <= collectionView.contentOffset.y
    }
    
    func scrollToBottom(animated: Bool = true, completion: (() -> Void)? = nil) {
        // I ask content size from the layout because on IOs 12 collection view contains not updated one
        let contentOffsetAtBottom = CGPoint(x: collectionView.contentOffset.x,
                                            y: chatLayout.collectionViewContentSize.height - collectionView.frame.height + collectionView.adjustedContentInset.bottom)
        
        guard contentOffsetAtBottom.y > collectionView.contentOffset.y else {
            completion?()
            return
        }
        
        let initialOffset = collectionView.contentOffset.y
        let delta = contentOffsetAtBottom.y - initialOffset
        if abs(delta) > chatLayout.visibleBounds.height {
            // See: https://dasdom.dev/posts/scrolling-a-collection-view-with-custom-duration/
            animator = ManualAnimator()
            animator?.animate(duration: TimeInterval(animated ? 0.25 : 0.1), curve: .easeInOut) { [weak self] percentage in
                guard let self else {
                    return
                }
                self.collectionView.contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: initialOffset + (delta * percentage))
                if percentage == 1.0 {
                    self.animator = nil
                    let positionSnapshot = ChatLayoutPositionSnapshot(indexPath: IndexPath(item: 0, section: 0), kind: .footer, edge: .bottom)
                    self.chatLayout.restoreContentOffset(with: positionSnapshot)
                    self.currentInterfaceActions.options.remove(.scrollingToBottom)
                    completion?()
                }
            }
        } else {
            currentInterfaceActions.options.insert(.scrollingToBottom)
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.collectionView.setContentOffset(contentOffsetAtBottom, animated: true)
            }, completion: { [weak self] _ in
                self?.currentInterfaceActions.options.remove(.scrollingToBottom)
                completion?()
            })
        }
    }
    
    func scrollToIndexPath(_ indexPath: IndexPath, animated: Bool, completion: (() -> Void)? = nil) {
        guard chatLayout.layoutAttributesForItem(at: indexPath) != nil else {
            return
        }
        
        guard animated else {
            let positionSnapshot = ChatLayoutPositionSnapshot(indexPath: indexPath, kind: .header, edge: .top)
            chatLayout.restoreContentOffset(with: positionSnapshot)
            completion?()
            return
        }
        
        let initialOffset = self.collectionView.contentOffset
        collectionView.isUserInteractionEnabled = false
        // See: https://dasdom.dev/posts/scrolling-a-collection-view-with-custom-duration/
        animator = ManualAnimator()
        animator?.animate(duration: TimeInterval(0.25), curve: .easeInOut) { [weak self] percentage in
            guard let self = self else { return }
            guard let attributesForItem = self.chatLayout.layoutAttributesForItem(at: indexPath) else {
                return
            }
            let itemContentOffset = CGPoint(x: initialOffset.x,
                                            y: attributesForItem.frame.minY - self.collectionView.adjustedContentInset.top - self.chatLayout.settings.additionalInsets.top)

            let delta = itemContentOffset.y - initialOffset.y
            let contentOffsetAtBottom = CGPoint(x: self.collectionView.contentOffset.x, y: self.chatLayout.collectionViewContentSize.height - self.collectionView.frame.height + self.collectionView.adjustedContentInset.bottom)

            self.collectionView.contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: min(contentOffsetAtBottom.y,initialOffset.y + (delta * percentage)))
            if percentage == 1.0 {
                self.animator = nil
                let context = ChatLayoutInvalidationContext()
                context.invalidateLayoutMetrics = false
                self.chatLayout.invalidateLayout(with: context)
                self.collectionView.setNeedsLayout()
                self.collectionView.layoutIfNeeded()
                self.currentInterfaceActions.options.remove(.scrollingToBottom)
                self.collectionView.isUserInteractionEnabled = true
                completion?()
            }
        }
    }
}

extension ChatViewController: UICollectionViewDelegate {
    // Plan A
    /*
    private func copyAction(value: String) -> UIAction {
        return UIAction(title: "复制".innerLocalized(), image: UIImage(systemName: "doc.on.doc")) { [weak self] _ in
            let pasteboard = UIPasteboard.general
            pasteboard.string = value
        }
    }
    
    private func deleteAction(id: String) -> UIAction {
        return UIAction(title: "删除".innerLocalized(), image: UIImage(systemName: "trash")) { [weak self] _ in
            self?.chatController.defaultSelecteMessage(with: id)
            self?.chatController.deleteMessage()
        }
    }
    
    private func forwardAction(id: String) -> UIAction {
        return UIAction(title: "转发".innerLocalized(), image: UIImage(systemName: "arrowshape.turn.up.right")) { [weak self] _ in
            self?.chatController.defaultSelecteMessage(with: id)
            self?.forwardMessage(merge: false)
        }
    }
    
    private func replyAction(id: String, name: String, body: String) -> UIAction {
        return UIAction(title: "回复".innerLocalized(), image: UIImage(systemName: "ellipsis.message")) { [weak self] _ in
            self?.chatController.defaultSelecteMessage(with: id)
            self?.inputBarView.setReplyText(text: "\(name)：\(body)")
        }
    }
    
    private func selectedAction(id: String) -> UIAction{
        return UIAction(title: "多选".innerLocalized(), image: UIImage(systemName: "checkmark.circle")) { [weak self] _ in
            self?.setEditNotEdit()
            self?.showEditBottomView(messageID: id)
        }
    }
    
    private func revokeAction(id: String) -> UIAction{
        return UIAction(title: "撤回".innerLocalized(), image: UIImage(systemName: "arrow.uturn.left")) { [weak self] _ in
            self?.revokeMessage(with: id)
        }
    }
    
    @available(iOS 13.0, *)
    private func preview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let identifier = configuration.identifier as? String else {
            return nil
        }
        let components = identifier.split(separator: "|")
        guard components.count == 2,
              let sectionIndex = Int(components[0]),
              let itemIndex = Int(components[1]) else {
            return nil
        }
        
        let item = dataSource.sections[0].cells[itemIndex]
        var view: UIView?
        var targetView: UIView?
        var center: CGPoint!
        var parameters = UIPreviewParameters()
        
        switch item {
        case let .message(message, bubbleType: _):
            switch message.data {
            case .text, .mention(_):
                guard let cell = collectionView.cellForItem(at: IndexPath(item: itemIndex, section: sectionIndex)) as? TextMessageCollectionCell else { return nil }
                
                // `UITargetedPreview` doesnt support image mask (Why?) like the one I use to mask the message bubble in the example app.
                // So I replaced default `ImageMaskedView` with `BezierMaskedView` that can uses `UIBezierPath` to mask the message view
                // instead. So we are reusing that path here.
                //
                // NB: This way of creating the preview is not valid for long texts as `UITextView` within message view uses `CATiledLayer`
                // to render its content, so it may not render itself fully when it is partly outside the collection view. You will have to
                // recreate a brand new view that will behave as a preview. It is outside of the scope of the example app.
                view = cell.customView.customView.customView
                targetView = cell.customView.customView
                
                parameters.visiblePath = cell.customView.customView.customView.maskingPath
                center = cell.customView.customView.customView.center
                center.x += (message.type.isIncoming ? cell.customView.customView.customView.offset - 16 : -cell.customView.customView.customView.offset) / 2 + 8

            case .image(_, isLocallyStored: _):
                
                guard let cell = collectionView.cellForItem(at: IndexPath(item: itemIndex, section: sectionIndex)) as? ImageCollectionCell else { return nil }
                view = cell.customView.customView.customView
                targetView = cell.customView.customView
                
                parameters.visiblePath = cell.customView.customView.customView.maskingPath
                center = cell.customView.customView.customView.customView.center
                center.x += (message.type.isIncoming ? cell.customView.customView.customView.offset + StandardUI.avatarWidth + 28: -cell.customView.customView.customView.offset) / 2 + 8
                
            case .video(_, isLocallyStored: _):
                
                guard let cell = collectionView.cellForItem(at: IndexPath(item: itemIndex, section: sectionIndex)) as? VideoCollectionCell else { return nil }
                view = cell.customView.customView.customView
                targetView = cell.customView.customView
                
                parameters.visiblePath = cell.customView.customView.customView.maskingPath
                center = cell.customView.customView.customView.customView.center
                center.x += (message.type.isIncoming ? cell.customView.customView.customView.offset + StandardUI.avatarWidth + 28 : -cell.customView.customView.customView.offset) / 2 + 8
                
            case .audio(_, isLocallyStored: _):
                
                guard let cell = collectionView.cellForItem(at: IndexPath(item: itemIndex, section: sectionIndex)) as? AudioCollectionCell else { return nil }
                view = cell.customView.customView.customView
                targetView = cell.customView.customView
                
                parameters.visiblePath = cell.customView.customView.customView.maskingPath
                center = cell.customView.customView.customView.customView.center
                center.x += (message.type.isIncoming ? cell.customView.customView.customView.offset + StandardUI.avatarWidth + 8 : -cell.customView.customView.customView.offset) / 2 + 13
                
            case .file(_, isLocallyStored: _):
                
                guard let cell = collectionView.cellForItem(at: IndexPath(item: itemIndex, section: sectionIndex)) as? FileCollectionCell else { return nil }
                view = cell.customView.customView.customView
                targetView = cell.customView.customView
                
                parameters.visiblePath = cell.customView.customView.customView.maskingPath
                center = cell.customView.customView.customView.customView.center
                center.x += (message.type.isIncoming ? cell.customView.customView.customView.offset + 2 * StandardUI.avatarWidth - 4 : -cell.customView.customView.customView.offset) / 2 + 11
                
            case .quote(_):
                
                guard let cell = collectionView.cellForItem(at: IndexPath(item: itemIndex, section: sectionIndex)) as? ReplyCollectionCell else { return nil }
                view = cell.customView.customView.customView
                targetView = cell.customView.customView
                
                parameters.visiblePath = cell.customView.customView.customView.maskingPath
                center = cell.customView.customView.customView.customView.center
                center.x += (message.type.isIncoming ? cell.customView.customView.customView.offset + StandardUI.avatarWidth + 8 : -cell.customView.customView.customView.offset) / 2 + 13
                
            case .card(_):
                guard let cell = collectionView.cellForItem(at: IndexPath(item: itemIndex, section: sectionIndex)) as? CardCollectionCell else { return nil }
                view = cell.customView.customView.customView
                targetView = cell.customView.customView
                
                parameters.visiblePath = cell.customView.customView.customView.maskingPath
                center = cell.customView.customView.customView.customView.center
                center.x += (message.type.isIncoming ? cell.customView.customView.customView.offset + StandardUI.avatarWidth + 17 : -cell.customView.customView.customView.offset) / 2 + 11
            case .location(_):
                guard let cell = collectionView.cellForItem(at: IndexPath(item: itemIndex, section: sectionIndex)) as? LocationCollectionCell else { return nil }
                view = cell.customView.customView.customView
                targetView = cell.customView.customView
                
                parameters.visiblePath = cell.customView.customView.customView.maskingPath
                center = cell.customView.customView.customView.customView.center
                center.x += (message.type.isIncoming ? cell.customView.customView.customView.offset + StandardUI.avatarWidth + 17 : -cell.customView.customView.customView.offset) / 2 + 11
                
            default:
                return nil
            }
            if let view, let targetView {
                return UITargetedPreview(view: view,
                                         parameters: parameters,
                                         target: UIPreviewTarget(container: targetView, center: center))
            }
            return  nil
        default:
            return nil
        }
    }
    
    @available(iOS 13.0, *)
    public func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        preview(for: configuration)
    }
    
    @available(iOS 13.0, *)
    public func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        preview(for: configuration)
    }
    
    @available(iOS 13.0, *)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard !currentInterfaceActions.options.contains(.showingPreview),
              !currentControllerActions.options.contains(.updatingCollection),
                !currentInterfaceActions.options.contains(.editing) else {
            return nil
        }
        let item = dataSource.sections[indexPath.section].cells[indexPath.item]
        switch item {
        case let .message(message, bubbleType: _):
            var actions: [UIAction]?
            
            switch message.data {
            case let .text(source):
                guard source.type == .text else { return nil }
                actions = [copyAction(value: source.text),
                           deleteAction(id: message.id),
                           forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: source.text),
                           selectedAction(id: message.id)]
            case let .image(source, isLocallyStored: _):
                actions = [deleteAction(id: message.id),
                           forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: "[\("图片".innerLocalized())]"),
                           selectedAction(id: message.id)]
            case let .audio(source, isLocallyStored: _):
                actions = [deleteAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: "[\("语音".innerLocalized())]"),
                ]
            case let .video(source, isLocallyStored: _):
                actions = [deleteAction(id: message.id),
                           forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: "[\("视频".innerLocalized())]"),
                           selectedAction(id: message.id)]
            case let .file(source, isLocallyStored:_):
                actions = [deleteAction(id: message.id),
                           forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: "[\("文件".innerLocalized())]"),
                           selectedAction(id: message.id)
                ]
            case let .quote(source):
                actions = [deleteAction(id: message.id),
                           forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: source.text),
                           selectedAction(id: message.id)
                ]
            case let .mention(source):
                actions = [deleteAction(id: message.id),
                           forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: source.attributedString!.string),
                           selectedAction(id: message.id)
                ]
            case let .card(source):
                actions = [deleteAction(id: message.id),
                           forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: "[\("名片".innerLocalized())]"),
                           selectedAction(id: message.id)
                ]
            case let .location(source):
                actions = [deleteAction(id: message.id),
                           forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: "[\("定位".innerLocalized())]"),
                           selectedAction(id: message.id)
                ]
                
            default:
                return nil
            }
            if var actions {
                if chatController.canRevokeMessage(msg: message) {
                    actions.append(revokeAction(id: message.id))
                }
                let menu = UIMenu(title: "", children: actions)
                // Custom NSCopying identifier leads to the crash. No other requirements for the identifier to avoid the crash are provided.
                let identifier = "\(indexPath.section)|\(indexPath.item)" as NSString
                
                currentInterfaceActions.options.insert(.showingPreview)
                return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil, actionProvider: { _ in menu })
            }
            
            return nil
        default:
            return nil
        }
    }
    
    @available(iOS 13.2, *)
    func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        animator?.addCompletion {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // 预览抖动问题
                self.currentInterfaceActions.options.remove(.showingPreview)
            }
        }
    }
    */
    
    // Plan B
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = dataSource.sections[indexPath.section].cells[indexPath.item]

        if case .message(let msg, bubbleType: _) = item, case .sent(let info) = msg.status {
            if msg.type == .incoming {
                var isRead = false
                
                switch info.readedStatus {
                case .signalReaded(let readed):
                    isRead = readed
                case .groupReaded(let readed, _):
                    isRead = readed
                }
                if !isRead {
                    chatController.markMessageAsReaded(messageID: msg.id, completion: nil)
                }
            }
        }
    }
}

// MARK: ChatControllerDelegate

extension ChatViewController: ChatControllerDelegate {
    
    func friendInfoChanged(info: FriendInfo) {
        guard !hiddenInputBar else { return }
        let type = chatController.getConversation().conversationType
        
        setRightButtons(show: type == .c2c)
        titleView.mainLabel.text = info.showName
        titleView.mainTailLabel.isHidden = true
    }
    
    func groupInfoChanged(info: GroupInfo) {
        guard !hiddenInputBar else { return }
        
        self.setRightButtons(show: info.status == .ok || info.status == .muted)
        titleView.mainLabel.text = "\(info.groupName!)"
        titleView.mainTailLabel.text = "(\(info.memberCount))"
        
//        chatViewControllerNav.GroupTitleLbl.text =  "\(info.groupName!)(\(info.memberCount))"
        chatViewControllerNav.groupNumberLable.text = "[\(info.memberCount)]"
        
        self.showGroupAnnouncements(groupInfo: info)
    }
    
    func onlineStatus(status: UserStatusInfo) {
        titleView.showSubArea(status.statusDesc != nil)
        titleView.subLabel.text = status.statusDesc
        titleView.setDotHighlight(highlight: status.status == 1)
    }
    
    func roomParticipantChanged(isVideo: Bool, members: [GroupMemberInfo]) {
        showInMeetingView(show: members.count != 0, isVideo: isVideo, members: members)
    }
    
    func mute(info: MutedInfo) {
        if chatController.getConversation().conversationType == .c2c {
            otherIsInBlacklist = info.muted
        } else {
            mediaButton.isEnabled = !info.muted
            inputBarView.enableInput(enable: !info.muted)
            inputBarView.inputTextView.placeholder = info.muted ? info.mutedText : ""
        }
    }
    
    func didTapRead(messageID: String) {
        popover?.dismiss()

        guard !editNotifier.isEditing, chatController.getConversation().conversationType != .c2c else { return }
        
        if let msg = chatController.getMessageInfo(ids: [messageID]).first {
            let vc = UnreadListViewController(conversationID: chatController.getConversation().conversationID, clientMsgID: msg.clientMsgID)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func updateUnreadCount(count: Int) {
        if !editNotifier.isEditing {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: count > 0 ? (count > 99 ? "99+" : "\(count)") : nil, image: UIImage(nameInBundle: "common_back_icon")) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func isInGroup(with isIn: Bool) {
        guard !hiddenInputBar else { return }
        
        inputBarView.isHidden = !isIn
        if isIn {
            bottomTipsView?.removeFromSuperview()
            bottomTipsView = nil
            navigationItem.rightBarButtonItems = [settingButton, mediaButton]
        } else {
            if bottomTipsView == nil {
                bottomTipsView = EditingBottomTipsView()
                view.addSubview(bottomTipsView!)

                NSLayoutConstraint.activate([
                    bottomTipsView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    bottomTipsView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    bottomTipsView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            }
            navigationItem.rightBarButtonItems = nil
            self.chatViewControllerNav.moreImg.isHidden = true
        }
    }
    
    // MARK: - 张亚飞打的标记  点击消息
    func didTapContent(with id: String, data: Message.Data) {
        popover?.dismiss()
        print("-------------------------\(id)")
        func filterMediaSource(completion: @escaping ([MediaResource]) -> Void) {
            chatController.searchLocalMediaMessage { ms in
                let r = ms.flatMap { msg in
                    
                    if case .image(let source, _) = msg.data {
                        return MediaResource(thumbUrl: source.thumb?.url,
                                             url: source.source.url,
                                             type: .image,
                                             ID: msg.id)
                    }
                    if case .video(let source, _) = msg.data {
                        return MediaResource(thumbUrl: source.thumb?.url,
                                             url: source.source.url,
                                             type: .video,
                                             ID: msg.id)
                    }
                    if case .face(let source, _) = msg.data {
                        return MediaResource(thumbUrl: source.url,
                                             url: source.url,
                                             ID: msg.id)
                    }
                    if case .quote(let quoteMessageSource) = msg.data {
                        if case .image(let source, _) = quoteMessageSource.quote {
                            return MediaResource(thumbUrl: source.thumb?.url,
                                                 url: source.source.url,
                                                 type: .image,
                                                 ID: msg.id)
                        }
                        if case .video(let source, _) = quoteMessageSource.quote {
                            return MediaResource(thumbUrl: source.thumb?.url,
                                                 url: source.source.url,
                                                 type: .video,
                                                 ID: msg.id)
                        }
                    }
                    
                    return nil
                }
                
                completion(r)
            }
        }
        
        func previewMedias(currentIndexHandler: @escaping ([MediaResource]) -> (Int)) {
            filterMediaSource { [weak self] items in
                guard let self else { return }
                
                var index = currentIndexHandler(items)
                let vc = MediaPreviewViewController(resources: items, index: index)
                            
                vc.showIn(controller: self) { idx in
                    guard idx < items.count else { return nil }
                    let item = items[idx]
                    if let ID = item.ID, let tag = self.dataSource.mediaImageViews[ID] {
                        return self.collectionView.viewWithTag(tag)
                    }
                    
                    return nil
                }
                
                vc.onButtonAction = { [weak self] type in
                    self?.chatController.defaultSelecteMessage(with: id, onlySelect: false)
                    
                    if type == PreviewModalView.ActionType.forward {
                        self?.forwardMessage(merge: false)
                    }
                }
            }
        }
        
        switch data {
        case .text(let string):
            print(#file,#line, "张亚飞", "文本")
            break
        case .attributeText(let nSAttributedString):
            break
        case .url(let uRL, let isLocallyStored):
            if uRL.absoluteString.hasPrefix(linkSchme) {
                let userID = uRL.absoluteString.replacingOccurrences(of: linkSchme, with: "")
                
                if !userID.isEmpty, userID != chatController.getMentionAllFlag().tag {
//                    let vc = UserDetailTableViewController(userId: String(userID))
//                    navigationController?.pushViewController(vc, animated: true)
                    
                    if let handler = OIMApi.gotoUserMessageHandle {
                        handler(self, String(userID), "", "",{res in

                        })
                    }
                }
            } else if uRL.absoluteString.hasPrefix(reEditSchme) {
                
                let messageID = uRL.absoluteString.replacingOccurrences(of: reEditSchme, with: "")
                
                if let msg = RevokedMessageStorage.message(messageID: String(messageID)) {
                    let type = msg.contentType
                    
                    if type == .text {
                        if let text = msg.textElem?.content {
                            inputBarView.inputTextView.text = text
                            inputBarView.inputTextView.becomeFirstResponder()
                        }
                    } else if type == .at {
                        if let text = msg.atTextElem?.text {
                            setMentionText(mentionText: text)
                        }
                    } else if type == .quote {
                        let text = msg.quoteElem?.text ?? ""
                        let quoteElem = msg.quoteElem
                        
                        let name = quoteElem?.quoteMessage?.senderNickname ?? ""
                        //
                        chatController.defaultSelecteMessage(with: quoteElem?.quoteMessage?.clientMsgID, onlySelect: true)
                        inputBarView.inputTextView.text = text
                        inputBarView.setReplyText(text: "\(name)：\(text)")
                    }
                    
                }
            } else if uRL.absoluteString.hasPrefix(sendFriendReqSchme) {
                ProgressHUD.animate()
                chatController.addFriend { r in
//                    ProgressHUD.success("sendSuccessfully".innerLocalized())
                    ProgressHUD.dismiss()
                    if let handler = OIMApi.showTipHandle {
                                    
                        handler("sendSuccessfully".innerLocalized(), { res in
                           
                        })
                    }
                } onFailure: { errCode, errMsg in
//                    ProgressHUD.error("canNotAddFriends".innerLocalized())
                    ProgressHUD.dismiss()
                    if let handler = OIMApi.showTipHandle {
                                    
                        handler("canNotAddFriends".innerLocalized(), { res in
                           
                        })
                    }
                }
            }
        case .image(let source, let isLocallyStored):
            if source.ex?.isFace == true {
                var media = MediaResource(thumbUrl: source.thumb?.url,
                                          url: source.source.url,
                                          ID: id)
     
                let vc = MediaPreviewViewController(resources: [media])
                
                vc.showIn(controller: self) { [weak self] _ in
                    if let tag = self?.dataSource.mediaImageViews[id] {
                        return self?.collectionView.viewWithTag(tag)
                    }
                    
                    return nil
                }
            } else {
                previewMedias { items in
                    let index = items.firstIndex(where: { $0.url == source.source.url }) ?? 0
                    
                    return index
                }
            }
        case .video(let source, let isLocallyStored):
            previewMedias { items in
                let index = items.firstIndex(where: { $0.url == source.source.url }) ?? 0
                
                return index
            }
            
        case .audio(let source, let isLocallyStored):
            break
        case .file(let source, let isLocallyStored):
            showFile(url: source.url)
        case .quote(let msg):
            
            var media: MediaResource?
            
            if case .image(let source, _) = msg.quote {
                media = MediaResource(thumbUrl: source.thumb?.url,
                                      url: source.source.url,
                                      ID: id)
            } else if case .video(let source, _) = msg.quote {
                media = MediaResource(thumbUrl: source.thumb?.url,
                                      url: source.source.url,
                                      type: .video,
                                      ID: id)
            }
            
            if let media {
                let vc = MediaPreviewViewController(resources: [media])
                
                vc.showIn(controller: self) { [weak self] _ in
                    if let tag = self?.dataSource.mediaImageViews[id] {
                        return self?.collectionView.viewWithTag(tag)
                    }
                    
                    return nil
                }
            }
        case .merge(let source):
            guard let msgs = source.multiMessage else { return }
            let vc = ForwardListViewController(title: source.title, messages: msgs)
            navigationController?.pushViewController(vc, animated: false)
            
        case .card(let source):
//            let vc = UserDetailTableViewController(userId: source.user.id, groupId: chatController.getConversation().groupID, userDetailFor: .card)
//            navigationController?.pushViewController(vc, animated: true)
            if let handler = OIMApi.gotoUserMessageHandle {
                                handler(self, source.user.id, "", "",{res in

                                })
                            }
            
        case .location(let source):
            let vc = LocationViewController(LocationPoint(title: source.name, desc: source.address!, longitude: source.longitude, latitude: source.latitude))
            navigationController?.pushViewController(vc, animated: true)
            
        case .mention(let source):
            break
            
        case .notice(let source):
            if source.type == .oa {
                if let derictURL = source.derictURL, let url = URL(string: derictURL) {
                    UIApplication.shared.open(url)
                } else {
                    guard let snapshotUrl = source.snapshotUrl, !snapshotUrl.isEmpty else { return }
                    let vc = MediaPreviewViewController(resources: [MediaResource(thumbUrl: URL(string: snapshotUrl),
                                                                                  url: URL(string: snapshotUrl)!)])
                    vc.showIn(controller: self) { idx in
                        nil
                    }
                }
            } else {
                chatController.getGroupInfo(force: true, completion: { [weak self] groupInfo in
                    let vc = GroupAnnounceViewController(groupInfo: groupInfo)
                    self?.navigationController?.pushViewController(vc, animated: true)
                })
            }
        case .face(let source, _):
            break
        case .custom(let source):
            guard let value = source.value, let type = source.type else { return }
            switch type {
            case .call:
                let type = value["type"] as? String
                startMedia(isVideo: type == "video")
            case .meeting:
#if ENABLE_LIVE_ROOM
                ProgressHUD.animate()
                chatController.joinMeeting(meetingID: value["id"] as! String) { [weak self] invitaion in
                    ProgressHUD.dismiss()

                    guard let self, let invitaion else { return }
            
                    LiveRoomViewController.showIn(viewController: self, url: invitaion.url, token: invitaion.token)
                } onFailure: { errCode, errMsg in
                    ProgressHUD.dismiss()
                    if errMsg?.contains("roomIsNotExist") == true {
//                        ProgressHUD.error("会议已经结束！".innerLocalized())
//                        ProgressHUD.dismiss()
                        if let handler = OIMApi.showTipHandle {
                                        
                            handler("会议已经结束！".innerLocalized(), { res in
                               
                            })
                        }
                    } else {
//                        ProgressHUD.error("网络异常请稍后再试！".innerLocalized())
                        
                        if let handler = OIMApi.showTipHandle {
                                        
                            handler("网络异常请稍后再试！".innerLocalized(), { res in
                               
                            })
                        }
                    }
                }
#endif
            case .boke:
                // MARK: - 张亚飞打的标记  博客被点击
                print(source.bokeMessageSource.userBlogUrl)
                print("boke 被点击")
                if source.bokeMessageSource.userBlogUrl != nil {
                    gotoBokeLink(source.bokeMessageSource.userBlogUrl!)
                } else {
                    gotoBokeLink("")
                }
                
            default:
                break
            }

        }
        print("\(#function)")
    }
    
    func gotoBokeLink(_ link: String) {
        if let handler = OIMApi.showBokeLinkHandle {
            handler(self, link, {_ in 
                
            })
        }
    }
    
    private func showFile(url: URL) {
        documentInteractionController = UIDocumentInteractionController(url: url)
        documentInteractionController.delegate = self
        
        DispatchQueue.main.async { [self] in
            // 有些文件不能预览，就选择分享界面
            let r = documentInteractionController.presentPreview(animated: true)
            if !r {
                documentInteractionController.presentOptionsMenu(from: view.bounds, in: view, animated: true)
            }
        }
    }
    
    // MARK: ChatControllerDelegate
    
    func update(with sections: [Section], requiresIsolatedProcess: Bool) {
        
//        sections = sections.reversed()
        
        processUpdates(with: sections, animated: true, requiresIsolatedProcess: requiresIsolatedProcess)
    }
    
    private func processUpdates(with sections: [Section], animated: Bool = true, requiresIsolatedProcess: Bool, completion: (() -> Void)? = nil) {
        
        guard isViewLoaded else {
            dataSource.sections = sections
            return
        }
        
        guard currentInterfaceActions.options.isEmpty ||
                editNotifier.isEditing || // In edit mode, when a cell is selected, sliding the cell will cause the selected state to disappear.
                ignoreInterfaceActions else {
            let reaction = SetActor<Set<InterfaceActions>, ReactionTypes>.Reaction(type: .delayedUpdate,
                                                                                   action: .onEmpty,
                                                                                   executionType: .once,
                                                                                   actionBlock: { [weak self] in
                guard let self else {
                    return
                }
                self.processUpdates(with: sections, animated: animated, requiresIsolatedProcess: requiresIsolatedProcess, completion: completion)
            })
            currentInterfaceActions.add(reaction: reaction)
            return
        }
        
        func process() {
            
            if ignoreInterfaceActions { // only first load
                var changeSet = StagedChangeset(source: dataSource.sections, target: sections).flattenIfPossible()
                guard !changeSet.isEmpty else {
                    completion?()
                    return
                }
                guard let data = changeSet.last?.data else { 
                    completion?()
                    return
                }
                
                dataSource.sections = data
                
                if requiresIsolatedProcess {
                    chatLayout.processOnlyVisibleItemsOnAnimatedBatchUpdates = true
                    currentInterfaceActions.options.insert(.updatingCollectionInIsolation)
                }
                
                let positionSnapshot: ChatLayoutPositionSnapshot!
                if self.scrollToTop {
                    positionSnapshot = ChatLayoutPositionSnapshot(indexPath: IndexPath(item: 0, section: 0), kind: .header, edge: .top)
                } else {
                    positionSnapshot = ChatLayoutPositionSnapshot(indexPath: IndexPath(item: 0, section: sections.count - 1), kind: .footer, edge: .bottom)
                }
                
                self.collectionView.reloadData()
                // We want so that user on reload appeared at the very bottom of the layout
                self.chatLayout.restoreContentOffset(with: positionSnapshot)
                
                self.chatLayout.processOnlyVisibleItemsOnAnimatedBatchUpdates = false
                if requiresIsolatedProcess {
                    self.currentInterfaceActions.options.remove(.updatingCollectionInIsolation)
                }
                completion?()
                self.currentControllerActions.options.remove(.updatingCollection)
                
                return
            }
            // If there is a big amount of changes, it is better to move that calculation out of the main thread.
            // Here is on the main thread for the simplicity.
            var changeSet = StagedChangeset(source: dataSource.sections, target: sections).flattenIfPossible()
            guard !changeSet.isEmpty else {
                completion?()
                return
            }
            
            if requiresIsolatedProcess {
                chatLayout.processOnlyVisibleItemsOnAnimatedBatchUpdates = true
                currentInterfaceActions.options.insert(.updatingCollectionInIsolation)
            }
            currentControllerActions.options.insert(.updatingCollection)
            collectionView.reload(using: changeSet,
                                  interrupt: { changeSet in
                guard changeSet.sectionInserted.isEmpty else {
                    return true
                }
                return false
            },
                                  onInterruptedReload: {
                let positionSnapshot: ChatLayoutPositionSnapshot!
                if self.scrollToTop {
                    positionSnapshot = ChatLayoutPositionSnapshot(indexPath: IndexPath(item: 0, section: 0), kind: .header, edge: .top)
                } else {
                    positionSnapshot = ChatLayoutPositionSnapshot(indexPath: IndexPath(item: 0, section: sections.count - 1), kind: .footer, edge: .bottom)
                }
                self.collectionView.reloadData()
                // We want so that user on reload appeared at the very bottom of the layout
                self.chatLayout.restoreContentOffset(with: positionSnapshot)
            },
                                  completion: { _ in
                DispatchQueue.main.async { [self] in
                 
                    self.chatLayout.processOnlyVisibleItemsOnAnimatedBatchUpdates = false
                    if requiresIsolatedProcess {
                        self.currentInterfaceActions.options.remove(.updatingCollectionInIsolation)
                    }
                    completion?()
                    self.currentControllerActions.options.remove(.updatingCollection)
                }
            },
                                  setData: { data in
                self.dataSource.sections = data
            })
        }
        
        if animated {
            process()
        } else {
            UIView.performWithoutAnimation {
                process()
            }
        }
    }
    
}

// MARK: UIGestureRecognizerDelegate

extension ChatViewController: UIGestureRecognizerDelegate {
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        inputBarView.inputResignFirstResponder()
        resetOffset(newBottomInset: 0)
        popover?.dismiss()
    }
    
    @objc private func handleRevealPan(_ gesture: UIPanGestureRecognizer) {
        guard let collectionView = gesture.view as? UICollectionView,
              !editNotifier.isEditing else {
            currentInterfaceActions.options.remove(.showingAccessory)
            return
        }
        
        switch gesture.state {
        case .began:
            currentInterfaceActions.options.insert(.showingAccessory)
        case .changed:
            translationX = gesture.translation(in: gesture.view).x
            currentOffset += translationX
            
            gesture.setTranslation(.zero, in: gesture.view)
            updateTransforms(in: collectionView)
        default:
            UIView.animate(withDuration: 0.25, animations: { () in
                self.translationX = 0
                self.currentOffset = 0
                self.updateTransforms(in: collectionView, transform: .identity)
            }, completion: { _ in
                self.currentInterfaceActions.options.remove(.showingAccessory)
            })
        }
    }
    
    private func updateTransforms(in collectionView: UICollectionView, transform: CGAffineTransform? = nil) {
        collectionView.indexPathsForVisibleItems.forEach {
            guard let cell = collectionView.cellForItem(at: $0) else { return }
            updateTransform(transform: transform, cell: cell, indexPath: $0)
        }
    }
    
    private func updateTransform(transform: CGAffineTransform?, cell: UICollectionViewCell, indexPath: IndexPath) {
        var x = currentOffset
        
        let maxOffset: CGFloat = -100
        x = max(x, maxOffset)
        x = min(x, 0)
        
        swipeNotifier.setSwipeCompletionRate(x / maxOffset)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        [gestureRecognizer, otherGestureRecognizer].contains(panGesture)
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer, gesture == panGesture {
            let translation = gesture.translation(in: gesture.view)
            return (abs(translation.x) > abs(translation.y)) && (gesture == panGesture)
        }
        
        return true
    }
    
}

// MARK: CoustomInputBarAccessoryViewDelegate
// MARK: - 张亚飞打的标记   聊天界面底部功能菜单 代理
extension ChatViewController: CoustomInputBarAccessoryViewDelegate {
    
    func setBarBotomHeigthZero() {
        
    }
    
    
    private func completionHandler() -> ([Section]) -> Void {
        // 发送结束的操作
        let completion: ([Section]) -> Void = { [weak self] sections in
            self?.renderingMentionText = false
            self?.mentionCompletions.removeAll()
            self?.inputBarView.sendButton.stopAnimating()
            self?.currentInterfaceActions.options.remove(.sendingMessage)
            self?.processUpdates(with: sections, animated: true, requiresIsolatedProcess: false)
        }
        
        return completion
    }
    
    func uploadFile(image: UIImage,  completion: @escaping (URL) -> Void) {
        ProgressHUD.animate()
        chatController.uploadFile(image: image) { p in
            ProgressHUD.progress(p)
        } completion: { u in
            guard let u, let url = URL(string: u) else { return }
            completion(url)
            ProgressHUD.dismiss()
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {

        if text.isEmpty, !renderingMentionText {
            mentionCompletions.removeAll()
        }
    }
    
    public func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        guard !currentInterfaceActions.options.contains(.sendingMessage) else {
            return
        }
        scrollToBottom()
    }
    
    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let messageText = inputBar.inputTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        // 发送结束的操作
        let completion = completionHandler()
        
        currentInterfaceActions.options.insert(.sendingMessage)
        
        guard !messageText.isEmpty else {
            self.currentInterfaceActions.options.remove(.sendingMessage)
            return
        }
        
        // If there are members who are reminded
        chatController.defaultSelecteUsers(with: mentionCompletions.map { $0.context?["id"] as! String })
        keepContentOffsetAtBottom = true
        
        if !mentionCompletions.isEmpty {
            renderingMentionText = true
        }
        
        self.scrollToBottom(completion: {
            inputBar.sendButton.startAnimating()
            self.chatController.sendMessage(.text(TextMessageSource(text: messageText)), completion: completion)
        })
        inputBar.inputTextView.text = String()
        inputBarView.setReplyText(text: nil)
        inputBar.invalidatePlugins()
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [CustomAttachment]) {
        // 发送结束的操作
        let completion = completionHandler()
        
        currentInterfaceActions.options.insert(.sendingMessage)
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        
        guard !attachments.isEmpty else {
            currentInterfaceActions.options.remove(.sendingMessage)
            return
        }
        keepContentOffsetAtBottom = true

        print(attachments)
        
//         MARK: -  底部显示
        scrollToBottom(completion: {

            inputBar.sendButton.startAnimating()
            attachments.forEach { attachment in

                switch attachment {

                case .image(let relativePath, let path):
                    let source = MediaMessageSource(source: MediaMessageSource.Info(url: URL(string: path)!, relativePath: relativePath))
                    
                    self.chatController.sendMessage(.image(source, isLocallyStored: true),
                                                    completion: completion)

                case .audio(let relativePath, let duration):
                    let source = MediaMessageSource(source: MediaMessageSource.Info(relativePath: relativePath), duration: duration)
                    
                    self.chatController.sendMessage(.audio(source, isLocallyStored: true), completion: completion)
                    
                case .video(let thumbRelativePath, let thumbPath, let mediaRelativePath, let duration):
                    let source = MediaMessageSource(source: MediaMessageSource.Info(relativePath: mediaRelativePath),
                                                    thumb: MediaMessageSource.Info(url: URL(string: thumbPath)!, relativePath: thumbRelativePath),
                                                    duration: duration)
                    
                    self.chatController.sendMessage(.video(source, isLocallyStored: true), completion: completion)
                    
                case .file(let path):
                    let source = FileMessageSource(url: URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!))
                    
                    self.chatController.sendMessage(.file(source, isLocallyStored: true), completion: completion)
                    
                case .face(let url, let localPath):
                    let source = FaceMessageSource(localPath: localPath, url: url, index: -1)
                    
                    self.chatController.sendMessage(.face(source, isLocallyStored: false), completion: completion)
                case .boke(let source):
                    print(#file, #line, "发送博客")
                default:
                    print("暂未开放")
                    
                }
            }
        })
    }
    
    // MARK: - 张亚飞打的标记  第三步 遵循代理实现点击方法
    func inputBar(_ inputBar: InputBarAccessoryView, didPressPadItemWith type: PadItemType) {
//        resetOffset(newBottomInset: 0)
        
        switch type {
        case .media:
            showMediaLinkSheet()
        case .card:
            showSelectContacts()
        case .location:
            showLocationView()
        case .boke:
            resetOffset(newBottomInset: 0, duration: 0)
            showBokeView()
        case .videoCall:
            chooseVoiceORVideo(isVideo: true)
        case .voiceCall:
            chooseVoiceORVideo(isVideo: false)
        default:
            break
        }
    }
    
    
    
    
    func didPressRemoveReplyButton() {
        chatController.defaultSelecteMessage(with: nil, onlySelect: false)
    }
    
    func inputTextViewDidChange() {
        chatController.typing(doing: true)
    }
    
    private func showSelectContacts() {
        // 发送结束的操作
        let completion = completionHandler()
#if ENABLE_ORGANIZATION
        let vc = MyContactsViewController(types: [.friends, .staff])
#else
        let vc = MyContactsViewController(types: [.friends])
#endif
        vc.allowsSelecteAll = false
        
        vc.selectedContact { [weak self, weak vc] info in
            guard let self, let vc, let user = info.first else { return }
            let alertController = UIAlertController(title: nil, message: "确定发送该名片到聊天吗".innerLocalized(), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "取消".innerLocalized(), style: .cancel))
            alertController.addAction(UIAlertAction(title: "确定".innerLocalized(), style: .default, handler: { [self] _ in
                self.dismiss(animated: true)
                
                let source = CardMessageSource(user: User(id: user.ID!, name: user.name!, faceURL: user.faceURL, type: user.type))
                self.chatController.sendMessage(.card(source), completion: completion)
            }))
            vc.present(alertController, animated: true)
        }
        
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    private func showLocationView() {
        // 发送结束的操作
        let completion = completionHandler()
        
        let vc = LocationViewController()
        vc.onSendLocation { point in
            let source = LocationMessageSource(desc: point.desc, latitude: point.latitude, longitude: point.longitude)
            
            self.chatController.sendMessage(.location(source), completion: completion)
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 张亚飞打的标记  第四步 展示博客列表 博客聊表被点击 返回参数  发送博客信息  
    private func showBokeView()  {
        let completion = completionHandler()
        
        if let handler = OIMApi.showBokeSheetHandle {
            handler(self, { [weak self]res in
                print(#file, #line, res)
//                let dataStr = String.init(data: try! JSONSerialization.data(withJSONObject: ["customType": customType.rawValue,
//                                                                                                     "data": data]),
//                                                  encoding: .utf8)!
//                        return OIMMessageInfo.createCustomMessage(dataStr, extension: nil, description: nil).toMessageInfo()
                
               
//                let result = "博客标题####博客图片####博客链接"
                let source = CustomMessageSource(data: self?.getCustomBokeData(res))
                self?.chatController.sendMessage(.custom(source), completion: completion)
            })
        }
    }
    
    func getCustomBokeData(_ title: String) -> String {
//        let arr = title.components(separatedBy: "####")
//        let parm  = ["customType": 10500, "data": ["title": arr[0],"iconUrl": arr[1], "linkUrl":arr[2], "intro":arr[3] ]] as [String : Any]
        
        guard let jsonData = title.data(using: .utf8) else {
            return ""
        }
        
        do {
            let boke = try JSONDecoder().decode(bokeMessageSource.self, from: jsonData)
            
            let param = ["customType": 10500, "data":["id": boke.id,
                                                     "sign":boke.sign,
                                                     "userBlogUrl":boke.userBlogUrl,
                                                     "userBlogIntro":boke.userBlogIntro,
                                                     "userBlogName": boke.userBlogName,
                                                     "userBlogCreatIp":boke.userBlogCreatIp,
                                                     "userBlogCreatAffiliatingArea": boke.userBlogCreatAffiliatingArea,
                                                     "userBlogOrder":boke.userBlogOrder,
                                                     "userId":boke.userId,
                                                     "isDelete":boke.isDelete,
                                                     "creationTime":boke.creationTime,
                                                     "userBlogIcon":boke.userBlogIcon,
                                                     "changeTime":boke.changeTime]]  as [String : Any]
            
            do {
                let datastr = String.init(data: try JSONSerialization.data(withJSONObject: param), encoding: .utf8)
                return datastr!
            } catch {
                return ""
            }
            
        } catch {
            return ""
            print(error.localizedDescription)
        }
        
       
        
    }
    
    
    
}

extension ChatViewController: AutocompleteManagerDelegate {
    
    func autocompleteManager(_: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, didRemove completion: AutocompleteCompletion?) {
        guard let completion else { return }
        
        mentionCompletions.removeAll(where: { $0.context?["id"] as? String == completion.context?["id"] as? String })
    }
    
    // MARK: - AutocompleteManagerDelegate Helper
    
    func setAutocompleteManager(active: Bool) {
        guard active,
              presentedViewController == nil,
              !renderingMentionText,
              chatController.getConversation().conversationType == .superGroup else { return }
        
        let vc = MentionViewController(types: [.members], sourceID: chatController.getConversation().groupID, allowsMultipleSelection: false)
        
        vc.selectedContact(hasSelected: []) { [self] _, infos in
            
            let cs = infos.map({ AutocompleteCompletion(text: $0.name!, context: ["id": $0.ID! ])})
            
            autocompleteManager.submitMultipleCompletions(with: cs)
            mentionCompletions.append(contentsOf: cs)
            renderingMentionText = false

            dismiss(animated: true)
        }
        
        if chatController.getIsAdminOrOwner() {
            vc.mentionAll = { [weak self] in
                guard let self else { return }
                
                let flag = chatController.getMentionAllFlag()
                let cs = AutocompleteCompletion(text: flag.text, context: ["id": flag.tag ])
                
                autocompleteManager.submitMultipleCompletions(with: [cs])
                mentionCompletions.append(cs)
                renderingMentionText = false
                
                dismiss(animated: true)
            }
        }
        renderingMentionText = true
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
        /* Plan B
        let topStackView = inputBarView.topStackView
        if active, !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active, topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        inputBarView.invalidateIntrinsicContentSize()
         */
    }
}

// MARK: KeyboardListenerDelegate

extension ChatViewController: KeyboardListenerDelegate {
    
    func keyboardWillChangeFrame(info: KeyboardInfo) {
        guard !currentInterfaceActions.options.contains(.changingFrameSize),
              !currentInterfaceActions.options.contains(.showingPreview),
              collectionView.contentInsetAdjustmentBehavior != .never,
              let keyboardFrame = collectionView.window?.convert(info.frameEnd, to: view),
              keyboardFrame.minY > 0,
              inputBarView.inputTextView.isFirstResponder else { // The keyboard on the presented view will affect this.
            return
        }
                
        currentInterfaceActions.options.insert(.changingKeyboardFrame)
        let newBottomInset = UIScreen.main.bounds.height - keyboardFrame.minY
                
        if collectionView.contentInset.bottom != newBottomInset {
            let positionSnapshot = chatLayout.getContentOffsetSnapshot(from: .bottom)
            
            // Interrupting current update animation if user starts to scroll while batchUpdate is performed.
            if currentControllerActions.options.contains(.updatingCollection) {
                UIView.performWithoutAnimation {
                    self.collectionView.performBatchUpdates({})
                }
            }
            
            // Blocks possible updates when keyboard is being hidden interactively
            currentInterfaceActions.options.insert(.changingContentInsets)
            inputBarViewBottomAnchor.constant = -newBottomInset
            
            UIView.animate(withDuration: info.animationDuration, animations: {
                
                self.view.layoutIfNeeded()
                
                if let positionSnapshot, !self.isUserInitiatedScrolling {
                    self.chatLayout.restoreContentOffset(with: positionSnapshot)
                }
                if #available(iOS 13.0, *) {
                } else {
                    // When contentInset is changed programmatically IOs 13 calls invalidate context automatically.
                    // this does not happen in ios 12 so we do it manually
                    self.collectionView.collectionViewLayout.invalidateLayout()
                }
            }, completion: { _ in
                self.currentInterfaceActions.options.remove(.changingContentInsets)
            })
        }
        
        if newBottomInset == 0,
            info.frameEnd.minY == UIScreen.main.bounds.height,
            info.frameEnd.minY > info.frameBegin.minY,
           inputBarView.inputTextView.inputView == nil { // If there is emoji/pad input, it will not be hidden.
            resetOffset(newBottomInset: newBottomInset, duration: info.animationDuration)
        }
    }
    
    // MARK: - 张亚飞打的标记  回收键盘
    func resetOffset(newBottomInset: CGFloat, duration: CGFloat = 0.25) {
        let positionSnapshot = chatLayout.getContentOffsetSnapshot(from: .bottom)
        inputBarViewBottomAnchor.constant = -newBottomInset
        
        UIView.animate(withDuration: duration, animations: {
            self.view.layoutIfNeeded()
        })

        if let positionSnapshot, !self.isUserInitiatedScrolling {
            self.chatLayout.restoreContentOffset(with: positionSnapshot)
        }
        self.currentInterfaceActions.options.remove(.changingContentInsets)
    }
    
    
    func keyboardDidChangeFrame(info: KeyboardInfo) {
        guard currentInterfaceActions.options.contains(.changingKeyboardFrame) else {
            return
        }
        currentInterfaceActions.options.remove(.changingKeyboardFrame)
    }
    
    func keyboardWillShow(info: KeyboardInfo) {
        scrollToBottom(animated: false)
    }
    
    func keyboardWillHide(info: KeyboardInfo) {
        if info.frameBegin.height > 200.0 {
            chatController.typing(doing: false)
        }
    }
}

// MARK: EditingBottomControllerDelegate

extension ChatViewController: EditingBottomControllerDelegate {
    func canceleChoose() {
        print("取消")
        setEditNotEdit(forceEnd: false)
    }
    
    func deleteMessage() {
        ProgressHUD.animate()
        chatController.deleteMessage { [weak self] in
            ProgressHUD.dismiss()
            self?.setEditNotEdit(forceEnd: true)
        }
    }
    
    func forwardMessage(merge: Bool) {
        inputBarView.inputTextView.resignFirstResponder()
        
        var title: String!
        let msgCount = chatController.getSelectedMessages().count
        if  msgCount == 1 {
            title = chatController.getSelectedMessages().first?.getSummary()
        } else {
            if chatController.getConversation().conversationType == .c2c {
                chatController.getOtherInfo { [weak self] others in
                    guard let self else { return }
                    let aNickname = SuperStringUtil.getUserState(showname: others.publicInfo?.nickname ?? "").n
                    let bNickname =  SuperStringUtil.getUserState(showname: self.chatController.getSelfInfo()?.nickname ?? "").n
                    
                    title = "aWithbChatHistory".innerLocalizedFormat(arguments: aNickname, bNickname)
                }
            } else {
                title = "groupChatHistory".innerLocalized()
            }
        }
        
#if ENABLE_ORGANIZATION
        let vc = MyContactsViewController(types: [.friends, .groups, .staff, .recent], multipleSelected: true)
#else
        let vc = MyContactsViewController(types: [.friends, .groups, .recent], multipleSelected: true)
#endif
        vc.title = "转发消息".innerLocalized()
        vc.selectedHandler = { [weak self, weak vc] infos in
            guard let self, let vc else { return }

            let forwardCard = ForwardCard(frame: view.bounds)
            vc.view.addSubview(forwardCard)

            forwardCard.contentLabel.text = title

            forwardCard.numberOfItems = {
                return infos.count
            }

            // 转发弹窗用户信息
            forwardCard.itemForIndex = { index in
                return User(id: infos[index].ID!, name: infos[index].name!, faceURL: infos[index].faceURL ,type: infos[index].type)
            }

            forwardCard.cancelHandler = {
                forwardCard.removeFromSuperview()
            }

            forwardCard.confirmHandler = { [weak self] text in
                forwardCard.removeFromSuperview()

                guard let self else { return }
                
                var groupsID: [String] = []
                var usersID: [String] = []
                
                infos.forEach { info in
                    if info.type == .group {
                        groupsID.append(info.ID!)
                    } else {
                        usersID.append(info.ID!)
                    }
                }
                
                chatController.forwardMessage(merge: merge, usersID: usersID, groupsID: groupsID, title: title, attachMessage: text)
                
                vc.dismiss(animated: true)
                setEditNotEdit(forceEnd: true)
            }

            forwardCard.reloadData()
        }
        let nav = UINavigationController(rootViewController: vc)
        topMostViewController().present(nav, animated: true)
    }
}

extension ChatViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return view
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return view.frame
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        print("Dismissed!!!")
    }
}

// Plan B
extension ChatViewController: GestureDelegate {
    
    private func copyAction(value: String) -> PopoverCollectionViewController.MenuItem {
        return PopoverCollectionViewController.MenuItem(title: ToolItem.copy.title, image: ToolItem.copy.image) { [weak self] in
            let pasteboard = UIPasteboard.general
            pasteboard.string = value
        }
    }
    
    private func deleteAction(id: String) -> PopoverCollectionViewController.MenuItem {
        return PopoverCollectionViewController.MenuItem(title: ToolItem.delete.title, image: ToolItem.delete.image) { [weak self] in
            self?.chatController.defaultSelecteMessage(with: id, onlySelect: false)
            ProgressHUD.animate()
            self?.chatController.deleteMessage { [weak self] in
                ProgressHUD.dismiss()
                self?.setEditNotEdit(forceEnd: true)
            }
        }
    }
    
    private func forwardAction(id: String) -> PopoverCollectionViewController.MenuItem {
        return PopoverCollectionViewController.MenuItem(title: ToolItem.forward.title, image: ToolItem.forward.image) { [weak self] in
            self?.chatController.defaultSelecteMessage(with: id, onlySelect: false)
            self?.forwardMessage(merge: false)
        }
    }
    
    private func replyAction(id: String, name: String, body: String) -> PopoverCollectionViewController.MenuItem {
        return PopoverCollectionViewController.MenuItem(title: ToolItem.reply.title, image: ToolItem.reply.image) { [weak self] in
            self?.chatController.defaultSelecteMessage(with: id, onlySelect: false)
            self?.inputBarView.setReplyText(text: "\(name)：\(body)")
        }
    }
    
    private func selectedAction(id: String) -> PopoverCollectionViewController.MenuItem {
        return PopoverCollectionViewController.MenuItem(title: ToolItem.muiltSelection.title, image: ToolItem.muiltSelection.image) { [weak self] in
            self?.inputBarView.inputTextView.resignFirstResponder()
            self?.chatController.defaultSelecteMessage(with: id, onlySelect: false)
            self?.setEditNotEdit()
            self?.showEditBottomView(messageID: id)
        }
    }
    
    private func revokeAction(id: String) -> PopoverCollectionViewController.MenuItem {
        return PopoverCollectionViewController.MenuItem(title: ToolItem.revoke.title, image: ToolItem.revoke.image) { [weak self] in
            ProgressHUD.animate()
            self?.revokeMessage(with: id) {
                ProgressHUD.dismiss()
            }
        }
    }
    
    
    private func starAction(id: String, source: bokeMessageSource) -> PopoverCollectionViewController.MenuItem {
        return PopoverCollectionViewController.MenuItem(title: ToolItem.star.title, image: ToolItem.star.image) { [weak self] in
            print("收藏", source)
            
//            if let handler = OIMApi.showBokeSheetHandle {
//                handler(self, { [weak self]res in
//                    print(#file, #line, res)
//
//                    let source = CustomMessageSource(data: self?.getCustomBokeData(res))
//                    self?.chatController.sendMessage(.custom(source), completion: completion)
//                })
//            }
            
//            if let handler = OIMApi.starBokeLinkHandle {
//                handler(source.userBlogName ?? "" , source.userBlogIcon ?? "", source.userBlogUrl ?? "", source.userBlogIntro  ?? "",  {[weak self] res in
//                    
//                })
//            }
            
            if let handler = OIMApi.starBokeLinkHandle {
                
                let encoder = JSONEncoder()
                do  {
                    let jsondata = try encoder.encode(source)
                    if let jsonString = String(data: jsondata, encoding: .utf8) {
                        handler(jsonString,  {[weak self] res in
                                               
                                           })

                    }
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            
        }
    }
    
    // MARK: - 张亚飞打的标记 长按手势 代理
    func longPress(with indexPath: IndexPath, sourceView: UIView, point: CGPoint) {
        
        guard !editNotifier.isEditing else { return }
    
        keepContentOffsetAtBottom = false
        
        let item = dataSource.sections[indexPath.section].cells[indexPath.item]
        print("longPress:\(item)")
        
        if hiddenInputBar {
            if case .message(let msg, _) = item {
                if case .text(let source) = msg.data {
                    popover = PopoverCollectionViewController(items: [copyAction(value: source.text)])
                    popover!.show(in: self, sender: sourceView, point: point, passthroughViews: collectionView.subviews)
                    
                    popover!.onDismiss = { [weak self] in
                        self?.keepContentOffsetAtBottom = true
                    }
                }
            }
            return
        }
        
        switch item {
        case let .message(message, bubbleType: _):
            var actions: [PopoverCollectionViewController.MenuItem]?
            
            switch message.data {
            case let .text(source):
                if source.type == .text {
                    
                    actions = [copyAction(value: source.text),
                               forwardAction(id: message.id),
                               replyAction(id: message.id, name: message.owner.name, body: source.text),
                               selectedAction(id: message.id)]
                } else {
                    actions = [copyAction(value: source.text ?? "")]
                }
            case let .image(source, isLocallyStored: _):
                actions = [forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: "[\("图片".innerLocalized())]"),
                           selectedAction(id: message.id)]
            case let .audio(source, isLocallyStored: _):
                actions = [/*replyAction(id: message.id, name: message.owner.name, body: "[\("语音".innerLocalized())]"),*/
                ]
            case let .video(source, isLocallyStored: _):
                actions = [forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: "[\("视频".innerLocalized())]"),
                           selectedAction(id: message.id)]
            case let .file(source, isLocallyStored:_):
                actions = [forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: "[\("文件".innerLocalized())]"),
                           selectedAction(id: message.id)
                ]
            case let .quote(source):
                actions = [copyAction(value: source.text),
                           forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: source.text),
                           selectedAction(id: message.id)
                ]
            case let .merge(source):
                actions = [forwardAction(id: message.id),
                           selectedAction(id: message.id)]
                
            case let .mention(source):
                actions = [copyAction(value: source.attributedString?.string ?? ""),
                           forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: source.attributedString!.string),
                           selectedAction(id: message.id)
                ]
            case let .card(source):
                actions = [forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: "[\("名片".innerLocalized())]"),
                           selectedAction(id: message.id)
                ]
            case let .location(source):
                actions = [forwardAction(id: message.id),
                           replyAction(id: message.id, name: message.owner.name, body: "[\("定位".innerLocalized())]"),
                           selectedAction(id: message.id)
                ]
            case let .custom(source):
                if source.type == .boke {
                    actions = [forwardAction(id: message.id),
                               starAction(id: message.id, source: source.bokeMessageSource)]
                }
                break
            default:
                return
            }
            if var actions {
                if chatController.canRevokeMessage(msg: message) {
                    actions.append(revokeAction(id: message.id))
                }
                
//                if message.type == .outgoing {
                let d = deleteAction(id: message.id)
                actions.insert(d, at: 0)
//                }
                
                let visibleCells = collectionView.visibleCells
                var subviews = visibleCells.flatMap({ $0.contentView.subviews })
                let subviews2 = subviews.flatMap({ $0.subviews })
                let subviews3 = subviews2.filter({ $0 is UIStackView }) as [UIStackView]

                popover = PopoverCollectionViewController(items: actions)
                popover!.show(in: self, sender: sourceView, point: point, passthroughViews: subviews3)
                
                popover!.onDismiss = { [weak self] in
                    self?.keepContentOffsetAtBottom = true
                }
            }
            
            return
        default:
            return
        }
    }
    
    func didTapAvatar(with user: User) {
        popover?.dismiss()
        
        if chatController.getConversation().conversationType == .superGroup {
            chatController.getGroupInfo(force: false, completion: { [weak self] info in
                if info.lookMemberInfo != 1 {
//                    self?.chatController.getGroupMembers(userIDs: [user.id], memory: true) { [weak self] mi in
//                        let vc = UserDetailTableViewController(userId: user.id, groupInfo: info, groupMemberInfo: mi[0], userInfo: user.toSimpleFullUserInfo())
//                        self?.navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
//                        self?.navigationController?.pushViewController(vc, animated: true)
//                    }
                    
                    self?.chatController.getGroupMembers(userIDs: [user.id], memory: true) { [weak self] mi in
                        guard let self = self else {return}
                        if let handler = OIMApi.gotoUserMessageHandle {
                            handler(self, user.id, "",  "",{res in

                                            })
                                        }
                    }
                    
                   
                }
            })
        } else {
//            let vc = UserDetailTableViewController(userId: user.id, groupId: chatController.getConversation().groupID, userInfo: user.toSimpleFullUserInfo())
//            navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
//            navigationController?.pushViewController(vc, animated: true)
            
            if let handler = OIMApi.gotoUserMessageHandle {
                                handler(self, user.id, "",  "",{res in

                                })
                            }
        }
    }
    
    func didLongPressAvatar(with id: String, name: String) {
        guard chatController.getConversation().conversationType == .superGroup else { return }
        
        renderingMentionText = true
        let c = AutocompleteCompletion(text: name, context: ["id": id ])
                    
        autocompleteManager.submitMultipleCompletions(with: [c])
        mentionCompletions.append(c)
        
        if !inputBarView.inputTextView.isFirstResponder {
            inputBarView.inputBecomeFirstResponder()
            inputBarView.inputTextView.becomeFirstResponder()
            let range = NSMakeRange(inputBarView.inputTextView.text.count - 1, 1)
            inputBarView.inputTextView.scrollRangeToVisible(range)
        }
        renderingMentionText = false
    }
    
    func onTap(with indexPath: IndexPath) {
        let item = dataSource.sections[indexPath.section].cells[indexPath.item]

        switch item {
        case let .message(message, bubbleType: _):
            
            switch message.data {
            case .audio(let source, isLocallyStored: _):
                var ex = source.ex ?? MessageEx()
                ex.audioHasReaded = true
                chatController.updateMessageLocalEx(messageID: message.id, ex: ex)
            default:
                break
            }
        default:
            break
        }
    }
    
    func onTapEdgeAligningView() {
        popover?.dismiss()
    }
}
