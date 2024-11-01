
import OUICore
import OUICoreView
import SnapKit
import ProgressHUD
import Photos
import ZLPhotoBrowser

class PublishViewController: UIViewController {
    
    var forVideo: Bool!
    var maxMetasCount = 9
    var publishHandler: (() -> Void)?
    
    init(forVideo: Bool = false, publishHandler: (() -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.forVideo = forVideo
        self.maxMetasCount = forVideo ? 1 : 9
        self.publishHandler = publishHandler
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
        v.setConfigToMultipleSelected()
        v.didPhotoSelected = { [weak self] (images: [UIImage], assets: [PHAsset]) in
            guard !images.isEmpty else { return }
            
            for (index, asset) in assets.enumerated() {
                let thumb = images[index].compress(expectSize: 100 * 1024)
                let result = FileHelper.shared.saveImage(image: thumb)
                var thumbnailPath = result.fullPath
                
                switch asset.mediaType {
                case .video:
                    ProgressHUD.animate()
                    ZLVideoManager.exportVideo(for: asset, exportType: .mp4) { [weak self] (url: URL?, _: Error?) in
                        guard let url = url else { return }
                        self?.viewModel.metas.append(.init(thumb: thumbnailPath, original: url.relativePath))
                        self?.tableView.performBatchUpdates({
                            self?.tableView.reloadRows(at: [.init(row: 1, section: 0)], with: .none)
                        })
                        ProgressHUD.dismiss()
                    }
                    break
                case .image:
                    self?.viewModel.metas.append(.init(thumb: thumbnailPath, original: thumbnailPath))
                    self?.tableView.performBatchUpdates({
                        self?.tableView.reloadRows(at: [.init(row: 1, section: 0)], with: .none)
                    })
                    break
                default:
                    break
                }
            }
        }
        
        v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
            guard let self else { return }
            
            if self.forVideo {
                guard let videoPath else { return }
                ProgressHUD.animate()
                PhotoHelper.getVideoAt(url: videoPath) { main, thumb, duration in
                 
                    self.viewModel.metas.append(.init(thumb: thumb.fullPath, original: main.fullPath))
                    DispatchQueue.main.async {
                        self.tableView.performBatchUpdates({
                            self.tableView.reloadRows(at: [.init(row: 1, section: 0)], with: .none)
                        })
                    }
 
                    ProgressHUD.dismiss()
                }
            } else {
                if let photo = photo {
                    let result = FileHelper.shared.saveImage(image: photo)
                    
                    if result.isSuccess {
                        self.viewModel.metas.append(.init(thumb: result.fullPath, original: videoPath?.relativePath ?? result.fullPath))
                        self.tableView.performBatchUpdates({
                            self.tableView.reloadRows(at: [.init(row: 1, section: 0)], with: .none)
                        })
                    }
                }
            }
        }
        return v
    }()
    
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.delegate = self
        v.dataSource = self
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = 44
        v.keyboardDismissMode = .onDrag
        v.backgroundColor = .clear
        
        v.register(PublishInputTextCell.self, forCellReuseIdentifier: NSStringFromClass(PublishInputTextCell.self))
        v.register(PublishInputMetaCell.self, forCellReuseIdentifier: NSStringFromClass(PublishInputMetaCell.self))
        v.register(PublishSpaceCell.self, forCellReuseIdentifier: NSStringFromClass(PublishSpaceCell.self))
        v.register(PublishValueCell.self, forCellReuseIdentifier: NSStringFromClass(PublishValueCell.self))
        
        return v
    }()
    
    let rowItems: [RowType] = RowType.allCases
    let viewModel = PublishViewModel()
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        
        viewModel.type = forVideo ? 1 : 0
        
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        let completButton = UIBarButtonItem(title: "发布".innerLocalized(), style: .done, target: self, action: #selector(completion))
        navigationItem.setRightBarButton(completButton, animated: false)
    }
    
    @objc func completion() {
        view.endEditing(true)
        ProgressHUD.animate(interaction: false)
        viewModel.publishMoments { [weak self] r in
            guard let `self` = self else {
                ProgressHUD.dismiss()
                return
            }
            if r == nil {
                self.publishHandler?()
                ProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
            } else {
//                ProgressHUD.error(r)
                ProgressHUD.dismiss()
                if let handler = OIMApi.showTipHandle {
                                
                    handler(r ?? "", { res in
                       
                    })
                }
            }
        }
    }
    
    // 多媒体输入
    func showMetaInputView() {
        _photoHelper.setConfigToMultipleSelected(forVideo: forVideo, maxSelectCount: maxMetasCount - viewModel.metas.count)
        _photoHelper.showSelectMetaSheet(byController: self)
    }
    
    // 预览图片
    func browserImages(_ index: Int) {
        let sources = viewModel.metas.map{ MediaResource(thumbUrl: URL(fileURLWithPath: $0.original), url: URL(fileURLWithPath: $0.original)) }
        
        let vc = MediaPreviewViewController(resources: sources, index: index, showIndicator: true)
        vc.showIn(controller: navigationController!, senders: [])
        
        vc.onDelete = { [weak self] index in
            self?.viewModel.metas.remove(at: index)
            self?.tableView.performBatchUpdates({
                self?.tableView.reloadRows(at: [.init(row: 1, section: 0)], with: .none)
            })
        }
    }
    
    enum RowType: CaseIterable {
        static var allCases: [RowType] {
            return [.inputText, inputMetas, .spacing, .permission(false), .metion]
        }
        
        case inputText
        case inputMetas
        case spacing
        case permission(_ block: Bool = false)
        case metion
        
        var title: String {
            switch self {
            case .inputText:
                return ""
            case .inputMetas:
                return ""
            case .spacing:
                return ""
            case .permission(let block):
                return block ? "不给谁看".innerLocalized() : "谁可以看".innerLocalized()
            case .metion:
                return "提醒谁看".innerLocalized()
            }
        }
        
        var iconSting: String {
            switch self {
            case .inputText:
                return ""
            case .inputMetas:
                return ""
            case .spacing:
                return ""
            case .permission(let block):
                return "moments_eye_icon"
            case .metion:
                return "moments_mention_icon"
            }
        }
    }
}

extension PublishViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType: RowType = rowItems[indexPath.row]
        
        switch rowType {
        case .inputText:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PublishInputTextCell.self), for: indexPath) as! PublishInputTextCell
            cell.onChange = { [weak self] text in
                self?.viewModel.text = text
            }
            cell.separatorInset = .init(top: 0, left: CGRectGetWidth(tableView.bounds), bottom: 0, right: 0)
            return cell
        case .inputMetas:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PublishInputMetaCell.self), for: indexPath) as! PublishInputMetaCell
            cell.numberOfItems = { [weak self] in
                
                guard let count = self?.viewModel.metas.count else { return 0 }
                return count
            }
            cell.showAddButton = { [weak self] in
                
                guard let `self` = self else { return false }
                return self.viewModel.metas.count < self.maxMetasCount
            }
            cell.imagePathAtIndexPath = { [weak self] index in
                
                guard let `self` = self, index < self.viewModel.metas.count else { return nil }
                return self.viewModel.metas[index].thumb
            }
            cell.addViewOnItem = { [weak self] index in
                
                guard let `self` = self, self.forVideo, !self.viewModel.metas.isEmpty else { return nil }
                
                let play = UIImageView(image: .init(nameInBundle: "moments_video_play_icon"))
                return play
            }
            cell.onTap = { [weak self] index in
                
                guard let `self` = self else { return }
                if index == self.viewModel.metas.count {
                    // 如果点击的是+号
                    self.showMetaInputView()
                } else {
                    self.browserImages(index)
                }
            }
            cell.deleteImageAction = { [weak self] index in
                
                guard let `self` = self else { return }
                self.viewModel.metas.remove(at: index)
                self.tableView.reloadData()
            }
            
            cell.reloadData()
            
            return cell
        case .spacing:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PublishSpaceCell.self), for: indexPath) as! PublishSpaceCell
            
            return cell
        case .permission(let block):
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PublishValueCell.self), for: indexPath) as! PublishValueCell
            cell.iconImageView.image = .init(nameInBundle: rowType.iconSting)
            cell.titleLabel.text = rowType.title
            return cell
        case .metion:
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PublishValueCell.self), for: indexPath) as! PublishValueCell
            cell.iconImageView.image = .init(nameInBundle: rowType.iconSting)
            cell.titleLabel.text = rowType.title
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowType = rowItems[indexPath.row]
        
        switch rowType {
        case .permission(let block):
            let vc = PermissonViewController()
            vc.selectedItemsHandler = { [weak self] (type, friends, groups) in
                // 回传选中的人和群
                self?.viewModel.permissonFriends = friends.map({ $0.ID! })
                self?.viewModel.permissonGroups = groups.map({ $0.ID! })
                self?.viewModel.permisson = type.rawValue
                
                let cell = tableView.cellForRow(at: indexPath) as! PublishValueCell
                // 选择公开和私密展示一下
                if type == .public || type == .private {
                    cell.trailingLabel.text = type.title
                } else {
                    // 展示好友和群组名称
                    cell.trailingLabel.text = (friends.map {$0.name!} + groups.map {$0.name!}).joined(separator: "、")
                }
                cell.titleLabel.text = type == .part ? RowType.permission(false).title : RowType.permission(true).title
            }
            navigationController?.pushViewController(vc, animated: true)
        case .metion:
            let vc = SelectContactsViewController()
            vc.selectedContact(hasSelected: viewModel.metionContacts) { [weak self] _, contacts in
                let cell = tableView.cellForRow(at: indexPath) as! PublishValueCell
                cell.trailingLabel.text = contacts.map {$0.name!}.joined(separator: "、")
                
                self?.viewModel.metionContacts = contacts.map({ $0.ID! })
                self?.navigationController?.popViewController(animated: true)
            }
            vc.title = "从通讯录选择".innerLocalized()
            navigationController?.pushViewController(vc, animated: true)
        case .inputText:
            break
        case .inputMetas:
            break
        case .spacing:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType: RowType = rowItems[indexPath.row]
        
        switch rowType {
        case .inputText, .inputMetas:
            return UITableView.automaticDimension
        case .spacing:
            return 20
        case .permission(let blcok):
            return 60.h
        case .metion:
            return 60.h
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rowType: RowType = rowItems[indexPath.row]
        
        switch rowType {
        case .inputText, .inputMetas, .metion, .spacing:
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
        case .permission(_):
            cell.separatorInset = .zero

        }
    }
}

