
import OUICore
import OUICoreView
import IGListKit
import IGListDiffKit
import MJRefresh
import RxSwift
import SnapKit
import ProgressHUD

public class MomentsViewController: BaseIGListViewController {
    
    // MARK: - lazy var
    fileprivate var contentOffsetY: CGFloat = 0
    fileprivate var contentOffset: NSObjectProtocol?
    fileprivate let disposeBag = DisposeBag()
    
    private lazy var momentNavBar: MomentNavBar = {
        let nav = MomentNavBar(frame: .zero)
        
        nav.onClick = { [weak self] button in
            guard let `self` = self else { return }
            
            switch button.tag {
            case 100:
                self.navigationController?.popViewController(animated: true)
            case 200:
                let popover = PopoverTableViewController(items: menuItems)
                popover.topInset = 0
                popover.show(in: self, sender: button, permittedArrowDirections: [], sourceViewReviseOffset: 10)
            case 300:
                self.toNewMessageList()
            default:
                break
            }
        }
        return nav
    }()
    
    private lazy var menuItems: [PopoverTableViewController.MenuItem] = {
        let graphicsItem = PopoverTableViewController.MenuItem(title: "发布图文".innerLocalized(), icon: UIImage(nameInBundle: "moments_publish_graphics_icon")) { [weak self] in
            let vc = PublishViewController {
                self?.collectionView.mj_header?.beginRefreshing()
            }
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        let videoItem = PopoverTableViewController.MenuItem(title: "发布视频".innerLocalized(), icon: UIImage(nameInBundle: "moments_publish_video_icon")) { [weak self] in
            let vc = PublishViewController(forVideo: true) {
                self?.collectionView.mj_header?.beginRefreshing()
            }
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        return [graphicsItem, videoItem]
    }()
    
    var userID: String? // If userID is set, it is to load a person's circle of friends
    var momentID: String? // If momentID is set, a circle of friends is loaded and the header is blocked
    
    public init(userID: String? = nil, momentID: String? = nil, moments: MomentsInfo? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.userID = userID
        self.momentID = momentID
        viewModel = MomentsViewModel(userID: userID, momentID: momentID, moments: moments)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewModel: MomentsViewModel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.title = "朋友圈".innerLocalized()
        navigationItem.title =  "好友动态".localized()
        view.backgroundColor = .white
        
        addRefreshing()
        addNotification()
        bindData()
        viewModel.loadUserInfo()
        
        if viewModel.forDetail {
            collectionView.snp.removeConstraints()
            collectionView.snp.updateConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.leading.trailing.bottom.equalToSuperview()
            }
            viewModel.loadMoments()
        } else {
            view.addSubview(momentNavBar)
            momentNavBar.snp.makeConstraints { make in
                make.left.top.right.equalToSuperview()
                let h = CGRectGetMaxY(navigationController!.navigationBar.frame)
                make.height.equalTo(h)
            }
            collectionView.mj_header?.beginRefreshing()
        }
        
        adapter.scrollViewDelegate = self
        
        if userID != nil {
            // If it is a circle of friends with a specified user ID, block the release button
            momentNavBar.newMsgBtn.isHidden = true
            momentNavBar.publishBtn.isHidden = true
            momentNavBar.backBtn.isHidden = false
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.forDetail {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    deinit {
        print("MomentsViewController deinit")
    }
    
    private func bindData() {
        // do not display header for detail
        if !viewModel.forDetail {
            var headerInfo = HeaderInfo(userID: "", userName: "加载中".innerLocalized())
            objects.append(headerInfo)
            adapter.reloadData()
        }
        
        viewModel.userInfoRelay.subscribe(onNext: { [weak self] info in
            guard let self, let info else { return }
            objects[0] = info
            // Refresh data.
            if let sectionController = adapter.sectionController(for: objects.first) as? MomentsHeaderController {
                sectionController.updateInfo(info: info)
            }
        }).disposed(by: disposeBag)
        
        viewModel.momentsChangedRelay.subscribe(onNext: { [weak self] m in
            guard let self else { return }
            
            if let first = objects.first(where: { obj in
                if let o = obj as? MomentsInfo {
                    return o.workMomentID == m.workMomentID
                }
                return false
            }) {
                // Refresh data.
                if let sectionController = adapter.sectionController(for: first) as? MomentsListController {
                    sectionController.updateMoments(moments: m)
                }
            }
            
        }).disposed(by: disposeBag)
        
        viewModel.momentsRelay.subscribe(onNext: { [weak self] (ms: [MomentsInfo]) in
            guard let self else { return }
            self.collectionView.mj_footer?.resetNoMoreData()
            // Pull down to refresh
            if self.viewModel.pageNumber == 1 {
                if self.viewModel.forDetail {
                    if let m = ms.first {
                        self.objects.append(m)
                    }
                } else {
                    if self.objects.first is HeaderInfo {
                        self.objects.removeSubrange(1...)
                    } else {
                        self.objects.removeAll()
                    }
                    self.objects.append(contentsOf: ms)
                }
                
                self.collectionView.mj_header?.endRefreshing()
                
                if ms.isEmpty || ms.count < self.viewModel.pageCount {
                    if self.userID == nil && ms.isEmpty {
                        if var footer = self.collectionView.mj_footer as? MJRefreshAutoNormalFooter {
                            footer.setTitle("还没有动态，发布一条吧".innerLocalized(), for: .noMoreData)
                            footer.endRefreshingWithNoMoreData()
                        }
                    } else {
                        if var footer = self.collectionView.mj_footer as? MJRefreshAutoNormalFooter {
                            footer.setTitle("没有更多动态了".innerLocalized(), for: .noMoreData)
                            footer.endRefreshingWithNoMoreData()
                        }
                    }
                }
                
                self.adapter.reloadData()
            } else {
                // pull up load
                self.objects.append(contentsOf: ms)
                
                if ms.isEmpty || ms.count < self.viewModel.pageCount {
                    // Brand new without data, when there is data, the text of the footer needs to be corrected
                    if var footer = self.collectionView.mj_footer as? MJRefreshAutoNormalFooter {
                        footer.setTitle("没有更多动态了".innerLocalized(), for: .noMoreData)
                        footer.endRefreshingWithNoMoreData()
                    }
                } else {
                    self.adapter.performUpdates(animated: false, completion: nil)
                    self.collectionView.mj_footer?.endRefreshing()
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func addRefreshing() {
        
        let header = MomentRefreshHeader(refreshingBlock: {[weak self] in
            self?.viewModel.loadMoments()
        })
        header.lastUpdatedTime
        collectionView.mj_header = header
        
        if momentID == nil {
            // 查看单条详情，不展示加载
            let footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
                self?.viewModel.loadMoments(loadMore: true)
            })
            footer.isAutomaticallyRefresh = false
            collectionView.mj_footer = footer
        }
    }
}

// list 代理
extension MomentsViewController {
    public override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is MomentsInfo:
            
            let controller = MomentsListController()
            guard let info = object as? MomentsInfo else { return controller }
            
            controller.onTap = { [weak self] action in
                guard let self else {return}
                
                
                switch action {
                case .avatar:
                    let vc = OthersViewController(userID: info.userID, nickname: SuperStringUtil.getUserState(showname: info.nickname).n, faceURL: info.faceURL)
                    navigationController?.pushViewController(vc, animated: true)
                case .permisson:
                    let vc = PermissionUserListViewController(users: info.permissionUsers.map {ContactInfo(ID: $0.userID, name: $0.nickname, faceURL: $0.faceURL)})
                    let nav = UINavigationController(rootViewController: vc)
                    present(nav, animated: true)
                case .preview(let index, let senders):
                    if let sources = info.content?.metas.map { MediaResource(thumbUrl: $0.thumb.toURL(),
                                                                             url: $0.original.toURL()!,
                                                                             type: info.content?.type == 1 ? .video : .image) } {
                        let vc = MediaPreviewViewController(resources: sources, index: index)
                        
                        vc.showIn(controller: navigationController!, senders: senders)
                    }
                default:
                    break
                }
            }
            
            controller.onFavor = { [weak self] thumbup in
                ProgressHUD.animate(interaction: false)
                self?.viewModel.favor(momentID: info.workMomentID, like: !thumbup) { res in
                    guard let res else { return }
                    
                    controller.updateMoments(moments: res)
                    ProgressHUD.dismiss()
                }
            }
            
            controller.onComment = { [weak self] (replayUserID, text) in
                ProgressHUD.animate(interaction: false)
                self?.viewModel.comment(momentID: info.workMomentID, replyUserID: replayUserID, text: text, completion: { res in
                    guard let res else { return }
                    
                    controller.updateMoments(moments: res)
                    ProgressHUD.dismiss()
                })
            }
            
            controller.onDelete = { [weak self] (commentID) in
                guard let self else { return }
                
                if commentID == nil {
                    // Delete a post.
                    ProgressHUD.animate(interaction: false)
                    self.viewModel.delete(momentID: info.workMomentID) { success in
                        if success {
                            self.objects.removeAll { (element) -> Bool in
                                guard let ele = element as? MomentsInfo else {
                                    return false
                                }
                                return ele.workMomentID == info.workMomentID
                            }
                            self.adapter.performUpdates(animated: true, completion: nil)
                            ProgressHUD.dismiss()
                        }
                    }
                } else {
                    // delete a comment
                    ProgressHUD.animate(interaction: false)
                    self.viewModel.deleteComment(momentID: info.workMomentID, commentID: commentID!) { res in
                        guard let res else { return }
                        
                        controller.updateMoments(moments: res)
                        ProgressHUD.dismiss()
                    }
                }
            }
            
            return controller
        case is HeaderInfo:
            let section = MomentsHeaderController()
            section.onTap = { [weak self] type in
                switch type {
                case .newMessage:
                    self?.toNewMessageList()
                case .avatar:
                    let vc = MomentsViewController(userID: self?.userID ?? IMController.shared.uid)
                    vc.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            }
            return section
        default:
            fatalError()
        }
    }
    
    public override func emptyView(for listAdapter: ListAdapter) -> UIView? {
        
        if viewModel.emptyType == .beDeleted {
            let v = UILabel()
            v.textAlignment = .center
            v.text = "动态不见了".innerLocalized()
            
            return v
        } else if viewModel.emptyType == .none {
            let iconImageView = UIImageView(image: UIImage(nameInBundle: "moments_none_icon"))
            let tipsLabel = UILabel()
            tipsLabel.textAlignment = .center
            tipsLabel.text = "还没有动态，发布一条吧".innerLocalized()
            
            let vStack = UIStackView(arrangedSubviews: [iconImageView, tipsLabel])
            vStack.spacing = 8
            vStack.axis = .vertical
            vStack.alignment = .center
            
            let bg = UIView()
            
            bg.addSubview(vStack)
            vStack.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            return viewModel.forDetail ? nil : bg
        }
        
        
        return nil
    }
}

fileprivate extension MomentsViewController {
    
    func addNotification() {
        
        contentOffset = NotificationCenter.default.addObserver(forName: NSNotification.Name.list.contentOffset,
                                                               object: nil,
                                                               queue: OperationQueue.main,
                                                               using: {[weak self] (noti) in
            guard let offset = noti.object as? CGFloat, let self else {
                return
            }
            if offset < 0 { return }
            if offset == 0 {
                if viewModel.forDetail {
                    collectionView.setContentOffset(.zero, animated: false)
                }
            } else {
                collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
            }
        })
        
    }
    
    func toNewMessageList() {
        // Clear the unread count
        var header = self.objects.first as! HeaderInfo
        header.newMsgCount = 0
        self.adapter.reloadData()
        
        let vc = NewMessageViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - <UIScrollViewDelegate>

extension MomentsViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffsetY = scrollView.contentOffset.y
        
        print(contentOffsetY)
        
//        momentNavBar.navBarView.alpha = 1
//        momentNavBar.titleLabel.alpha = contentOffsetY / 150.h
//        
//        momentNavBar.titleLabel.alpha = 0
//        
//        momentNavBar.backgroundColor?.withAlphaComponent((150.h - contentOffsetY) / 150.h)
            
        
        if contentOffsetY > 222.h - (UIApplication.safeAreaInsets.top + UIApplication.statusBarHeight){
            momentNavBar.isScrollUp = true
            momentNavBar.backgroundColor = .white
        } else {
            momentNavBar.isScrollUp = false
            momentNavBar.backgroundColor = .clear
        }
    }
}
