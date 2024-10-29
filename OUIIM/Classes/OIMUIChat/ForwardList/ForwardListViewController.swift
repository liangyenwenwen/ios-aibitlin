import RxSwift
import OUICore
import OUICoreView
import ProgressHUD

#if ENABLE_LIVE_ROOM
import OUILive
#endif

open class ForwardListViewController: UIViewController {
    
    var messages: [[Message]] = []
    
    init(title: String, messages: [Message]) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        let temp = messages.sorted(by: { $0.date < $1.date })
        self.messages = splitByDay(source: temp)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(#function) - \(type(of: self))")
    }
    
    private var documentInteractionController: UIDocumentInteractionController!
    private let viewModel = ForwardListViewModel()
    private var prevMessage: Message?
    private var prevSecion = 0
    
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cF8F9FA
        
        
        initView()
    }
    
    private lazy var msgTableView: UITableView = {
        let v = UITableView(frame: .zero, style: .grouped)
        v.register(ForwardListTextCell.self, forCellReuseIdentifier: ForwardListTextCell.className)
        v.register(ForwardListImageCell.self, forCellReuseIdentifier: ForwardListImageCell.className)
        v.register(ForwardListCardCell.self, forCellReuseIdentifier: ForwardListCardCell.className)
        v.register(ForwardListLocationCell.self, forCellReuseIdentifier: ForwardListLocationCell.className)
        v.register(ForwardListFileCell.self, forCellReuseIdentifier: ForwardListFileCell.className)
        v.register(ForwardListAudioCell.self, forCellReuseIdentifier: ForwardListAudioCell.className)
        v.register(ForwardListMergeCell.self, forCellReuseIdentifier: ForwardListMergeCell.className)
        v.register(ForwardListBlankCustomCell.self, forCellReuseIdentifier: ForwardListBlankCustomCell.className)
        v.register(ForwardListCustomCell.self, forCellReuseIdentifier: ForwardListCustomCell.className)
        v.register(ForwardListQuoteCell.self, forCellReuseIdentifier: ForwardListQuoteCell.className)
        
        v.separatorColor = .sepratorColor
        v.estimatedRowHeight = 120
        v.rowHeight = UITableView.automaticDimension
        v.dataSource = self
        v.delegate = self
        v.separatorInset = UIEdgeInsets(top: 0, left: StandardUI.avatarWidth + 20, bottom: 0, right: 0)
        v.backgroundColor = .cF8F9FA
        v.tableFooterView = UIView()
        v.contentInsetAdjustmentBehavior = .never
        
        return v
    }()
    
    
    private func initView() {
        view.addSubview(msgTableView)
        msgTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(navigationController?.navigationBar.frame.maxY ?? 0)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    private func splitByDay(source: [Message]) -> [[Message]] {
        source.reduce(into: [[Message]]()) { result, current in
            guard var section = result.last,
                  let prev = section.last else {
                let section = [current]
                result.append(section)
                
                return
            }
            let prevDate = prev.date
            let date = current.date
            
            if Calendar.current.isDate(prevDate, equalTo: date, toGranularity: .day) {
                section.append(current)
                result[result.count - 1] = section
            } else {
                let section = [current]
                result.append(section)
            }
        }
    }
    
    private func configQuoteData(quote: Message.Data) -> (thumbURL: URL?, sourceURL: URL?, quoteAttributedString: NSAttributedString, isVideo: Bool) {
        var thumbURL: URL?
        var sourceURL: URL?
        var quoteAttributedString = NSMutableAttributedString()
        var isVideo = false
        
        switch quote {
        case .text(let source):
            quoteAttributedString.append(NSAttributedString(string: source.text))
            
        case .attributeText(let text):
            quoteAttributedString.append(text)
            
        case .mention(let source):
            quoteAttributedString.append(source.attributedString!)
            
        case .url(_, isLocallyStored: let isLocallyStored):
            break
            
        case .image(let s, isLocallyStored: let isLocallyStored):
            thumbURL = s.source.url.customThumbnailURL()
            sourceURL = s.source.url
            
        case .video(let s, isLocallyStored: let isLocallyStored):
            isVideo = true
            thumbURL = s.thumb?.url.customThumbnailURL()
            sourceURL = s.source.url
            
        case .audio(let s, isLocallyStored: let isLocallyStored):
            let attachStr = buildAttachmentString(image: UIImage(nameInBundle: "chat_msg_audio_record_normal"))
            quoteAttributedString.append(attachStr)
            quoteAttributedString.append(NSAttributedString(string: #"\#(s.duration!)"#))
            
        case .file(let s, isLocallyStored: let isLocallyStored):
            quoteAttributedString.append(NSAttributedString(string: "\(s.name!)"))
            let attachStr = buildAttachmentString(image: UIImage(nameInBundle: "chat_msg_file_zip_normal_icon"))
            quoteAttributedString.append(attachStr)
            
        case .merge(_):
            quoteAttributedString.append(NSAttributedString(string: "[\("chatRecord".innerLocalized())]"))
            
        case .card(let s):
            quoteAttributedString.append(NSAttributedString(string: "[\("carte".innerLocalized())] \(s.user.name)"))
            
        case .location(let s):
            quoteAttributedString.append(NSAttributedString(string: "[\("location".innerLocalized())]\(s.address ?? "") "))
            let attachStr = buildAttachmentString(image: UIImage(nameInBundle: "chat_msg_location_normal"), rect: CGRect(x: 0, y: -5, width: 16, height: 20))
            quoteAttributedString.append(attachStr)
            
        case .face(let s, isLocallyStored: let isLocallyStored):
            thumbURL = s.url.customThumbnailURL()
            sourceURL = s.url
         
        case .custom(_), .quote(_), .notice(_):
            break
//            // MARK: - 张亚飞打的标记  博客相关 待启用
//        case .boke(_):
//            print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n博客相关", #file, #line)
        }
        
        return (thumbURL, sourceURL, quoteAttributedString, isVideo)
    }
    
    private func buildAttachmentString(image: UIImage?, rect: CGRect = CGRect(x: 0, y: -5, width: 20, height: 20)) -> NSAttributedString {
        
        guard let image else { return NSAttributedString() }
        
        var attach = NSTextAttachment()
        attach.bounds = rect
        attach.image = image
        let attachStr = NSMutableAttributedString(attachment: attach)
        
        return attachStr
    }
}

extension ForwardListViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        messages.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.section][indexPath.row]
        let sender = msg.owner
        let sendTime = Date.timeString(date: msg.date)
        
        let avatarShouldHidden = prevMessage?.owner.id == msg.owner.id && prevSecion == indexPath.section
        
        switch msg.data {
        case .text(let source):
            let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListTextCell.className, for: indexPath) as! ForwardListTextCell
            cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
            cell.nikenameLabel.text = sender.name
            cell.dateTimeLabel.text = sendTime
            cell.textView.text = source.text
            
            cell.avatarView.isHidden = avatarShouldHidden
            prevMessage = msg
            prevSecion = indexPath.section
            
            return cell
        case .image(let source, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListImageCell.className, for: indexPath) as! ForwardListImageCell
            cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
            cell.nikenameLabel.text = sender.name
            cell.dateTimeLabel.text = sendTime
            
            let urlStr = source.thumb?.url ?? source.source.url
            cell.msgImageView.setImage(with: urlStr?.absoluteString, showIndicator: true) { _ in
                tableView.performBatchUpdates {
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
            
            cell.onTap = { [weak self] _ in
                guard let self else { return }
                
                let vc = MediaPreviewViewController(resources: [MediaResource(thumbUrl: source.thumb?.url, url: source.source.url)])
                
                vc.showIn(controller: self) { [weak cell] _ in
                    cell?.msgImageView
                }
            }
            
            cell.avatarView.isHidden = avatarShouldHidden
            prevMessage = msg
            prevSecion = indexPath.section
            
            return cell
        case .video(let source, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListImageCell.className, for: indexPath) as! ForwardListImageCell
            cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
            cell.nikenameLabel.text = sender.name
            cell.dateTimeLabel.text = sendTime
            cell.playImageView.isHidden = false
            
            let urlStr = source.thumb?.url ?? source.source.url
            cell.msgImageView.setImage(with: urlStr?.absoluteString, showIndicator: true) { _ in
                tableView.performBatchUpdates {
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
            
            cell.onTap = { [weak self] _ in
                guard let self else { return }
                
                let vc = MediaPreviewViewController(resources: [MediaResource(thumbUrl: source.thumb?.url, url: source.source.url, type: .video)])
                
                vc.showIn(controller: self) { [weak cell] _ in
                    cell?.msgImageView
                }
            }
            
            cell.avatarView.isHidden = avatarShouldHidden
            prevMessage = msg
            prevSecion = indexPath.section
            
            return cell
        case .audio(let source, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListAudioCell.className, for: indexPath) as! ForwardListAudioCell
            cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
            cell.nikenameLabel.text = sender.name
            cell.dateTimeLabel.text = sendTime
            
            cell.duration = source.duration ?? 0
            cell.url = source.source.url
            
            cell.avatarView.isHidden = avatarShouldHidden
            prevMessage = msg
            prevSecion = indexPath.section
            
            return cell
        case .file(let source, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListFileCell.className, for: indexPath) as! ForwardListFileCell
            cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
            cell.nikenameLabel.text = sender.name
            cell.dateTimeLabel.text = sendTime
            
            cell.nameLabel.text = source.name
            cell.length = source.length
            cell.url = source.url
            
            cell.onTap = { [weak self] path in
                guard let path else { return }
                
                let url = URL(fileURLWithPath: path)
                self?.showFile(url: url)
            }
            
            cell.avatarView.isHidden = avatarShouldHidden
            prevMessage = msg
            prevSecion = indexPath.section
            
            return cell
        case .quote(let source):
            let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListQuoteCell.className, for: indexPath) as! ForwardListQuoteCell
            cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
            cell.nikenameLabel.text = sender.name
            cell.dateTimeLabel.text = sendTime
            cell.textView.text = source.text
            
            let quote = configQuoteData(quote: source.quote!)
            cell.replyTextView.isHidden = quote.quoteAttributedString.length == 0
            
            if source.sender != nil {
                let base = NSMutableAttributedString(string: "\(source.sender!):")
                base.append(quote.quoteAttributedString)
                cell.replyTextView.attributedText = base
            } else {
                cell.replyTextView.attributedText = quote.quoteAttributedString
            }
            
            if let sourceURL = quote.sourceURL {
                cell.attachmentImageView.setImage(url: sourceURL, thumbURL: quote.thumbURL)
            }
            cell.playButtonImageView.isHidden = !quote.isVideo
            
            cell.onTap = { [weak self] _ in
                guard let self, let sourceURL = quote.sourceURL else { return }
                
                let vc = MediaPreviewViewController(resources: [MediaResource(thumbUrl: quote.thumbURL, url: sourceURL, type: quote.isVideo ? .video : .image)])
                
                vc.showIn(controller: self) { [weak cell] _ in
                    cell?.attachmentImageView
                }
            }
            
            cell.avatarView.isHidden = avatarShouldHidden
            prevMessage = msg
            prevSecion = indexPath.section
            
            return cell
        case .merge(let source):
            let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListMergeCell.className, for: indexPath) as! ForwardListMergeCell
            cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
            cell.nikenameLabel.text = sender.name
            cell.dateTimeLabel.text = sendTime
            
            cell.titleLabel.text = source.title
            cell.abstracts = source.abstractList
            
            cell.onTap = { [weak self] _ in
                if let messages = source.multiMessage {
                    let vc = ForwardListViewController(title: source.title, messages: messages)
                    
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            cell.avatarView.isHidden = avatarShouldHidden
            prevMessage = msg
            prevSecion = indexPath.section
            
            return cell
        case .card(let source):
            let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListCardCell.className, for: indexPath) as! ForwardListCardCell
            cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
            cell.nikenameLabel.text = sender.name
            cell.dateTimeLabel.text = sendTime
            
            cell.nameLabel.text = source.user.name
            cell.cardAvatarView.setAvatar(url: source.user.faceURL, text: source.user.name)
            
            cell.avatarView.isHidden = avatarShouldHidden
            prevMessage = msg
            prevSecion = indexPath.section
            
            return cell
        case .location(let source):
            let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListLocationCell.className, for: indexPath) as! ForwardListLocationCell
            cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
            cell.nikenameLabel.text = sender.name
            cell.dateTimeLabel.text = sendTime
            
            cell.nameLabel.text = source.name
            cell.addressLabel.text = source.address
            cell.mapImageView.setImage(with: source.url?.absoluteString, showIndicator: true)
            
            cell.avatarView.isHidden = avatarShouldHidden
            prevMessage = msg
            prevSecion = indexPath.section
            
            return cell
        case .mention(let source):
            let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListTextCell.className, for: indexPath) as! ForwardListTextCell
            cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
            cell.nikenameLabel.text = sender.name
            cell.dateTimeLabel.text = sendTime
            cell.textView.text = source.attributedString?.string
            
            cell.avatarView.isHidden = avatarShouldHidden
            prevMessage = msg
            prevSecion = indexPath.section
            
            return cell
            //        case .notice(_):
            //            <#code#>
        case .custom(let source):
            switch source.type {
            case .call:
                let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListCustomCell.className, for: indexPath) as! ForwardListCustomCell
                cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
                cell.nikenameLabel.text = sender.name
                cell.dateTimeLabel.text = sendTime
                
                cell.textView.attributedText = source.attributedString
                
                cell.avatarView.isHidden = avatarShouldHidden
                prevMessage = msg
                prevSecion = indexPath.section
                
                return cell
                //            case .customEmoji:
                //                <#code#>
                //            case .tagMessage:
                //                <#code#>
                //            case .moments:
                //                <#code#>
            case .meeting:
                let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListBlankCustomCell.className, for: indexPath) as! ForwardListBlankCustomCell
                cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
                cell.nikenameLabel.text = sender.name
                cell.dateTimeLabel.text = sendTime
                
                cell.textView.attributedText = source.attributedString
                
                cell.onTap = { [weak self] _ in
                    guard let self else { return }
#if ENABLE_LIVE_ROOM
                    ProgressHUD.animate()
                    guard let meetingID = source.value?["id"] as? String else { return }
                    viewModel.joinMeeting(meetingID: meetingID) { [self] invitaion in
                        guard let invitaion else { return }
                        ProgressHUD.dismiss()
                        LiveRoomViewController.showIn(viewController: self, url: invitaion.url, token: invitaion.token)

                    } onFailure: { errCode, errMsg in
                        ProgressHUD.dismiss()
                        if errMsg?.contains("roomIsNotExist") == true {
//                            ProgressHUD.error("会议已经结束！".innerLocalized())
                            if let handler = OIMApi.showTipHandle {
                                            
                                handler("会议已经结束！".innerLocalized(), { res in
                                   
                                })
                            }
                        } else {
//                            ProgressHUD.error("网络异常请稍后再试！".innerLocalized())
                            if let handler = OIMApi.showTipHandle {
                                            
                                handler("网络异常请稍后再试！".innerLocalized(), { res in
                                   
                                })
                            }
                        }
                    }
#endif
                }
                
                cell.avatarView.isHidden = avatarShouldHidden
                prevMessage = msg
                prevSecion = indexPath.section
                
                return cell
                //            case .blockedByFriend:
                //                <#code#>
                //            case .deletedByFriend:
                //                <#code#>
            default:
                break
            }
            //        case .face(_, isLocallyStored: let isLocallyStored):
            //            <#code#>
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ForwardListTextCell.className, for: indexPath) as! ForwardListTextCell
        cell.avatarView.setAvatar(url: sender.faceURL, text: sender.name)
        cell.nikenameLabel.text = sender.name
        cell.dateTimeLabel.text = sendTime
        cell.textView.text = "[特殊消息]"
        
        cell.avatarView.isHidden = avatarShouldHidden
        prevMessage = msg
        prevSecion = indexPath.section
        
        return cell
    }
    
    public func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let yearLabel = UILabel()
        yearLabel.textColor = .systemGray3
        yearLabel.font = .f12
        yearLabel.textAlignment = .center
        
        let date = messages[section][0].date
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Calendar.current.locale
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        let formatDateString = dateFormatter.string(from: date)
        
        yearLabel.text = formatDateString
        
        return yearLabel
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }
    
    public func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        32
    }
    
    public func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
}


extension ForwardListViewController: UIDocumentInteractionControllerDelegate {
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
    
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    public func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return view
    }
    
    public func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return view.frame
    }
    
    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        print("Dismissed!!!")
    }
}

extension ForwardListViewController {
    
}
