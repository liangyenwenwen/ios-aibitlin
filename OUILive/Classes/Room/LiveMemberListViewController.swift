
import Foundation
import UIKit
import OUICore
import OUICoreView
import RxSwift
import LiveKitClient

enum LiveMemberListOperate {
    case invite // 邀请
    case muteAll(_ isMuted: Bool) // 全员静音
}

enum LiveMemberOperate {
    case audio(_ isMuted: Bool)  // 是否允许音频
    case video(_ isMuted: Bool)  // 是否允许视频
    case more  // 更多
    case pined(_ isPined: Bool)   // 置顶
    case allSeeHim(_ isSee: Bool) // 全部看他
}


class LiveMemberListViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    var onTap: ((_ operate: LiveMemberListOperate) -> Void)!
    var numberOfitems: (() -> Int)!
    var participantForRowAt: ((_ index: Int) -> (participant: Participant, isPinged: Bool, showOperate: Bool, isAllSeeHim: Bool)?)! // 第二个参数是否置顶，第三个参数是否是admin，在meetinginfo里面
    var participantDidOperated: ((_ index: Int, _ operate: LiveMemberOperate) -> Void)?
    
    func reloadData() {
        DispatchQueue.main.async { [self] in
            tableView.reloadData()
        }
    }
    
    // 设置按钮是否可显示
    func updateButtonStatus(canInvite: Bool = false, canMuteAll: Bool = false) {
        inviteButton.isHidden = !canInvite
        muteAllButton.isHidden = !canMuteAll
//        unMuteAllButton.isHidden = !canMuteAll
    }
    
    private var selectedIndexPath: IndexPath?
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.text = "成员".innerLocalized()
        return v
    }()
    
    private lazy var inviteButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setTitle("邀请".innerLocalized(), for: .normal)
        v.titleLabel?.font = .f14
        v.layer.borderColor = UIColor.systemGray3.cgColor
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 6
        v.setTitleColor(.systemBlue, for: .normal)
        v.rx.tap.throttle(.seconds(2), scheduler: MainScheduler.instance).subscribe (onNext: { [weak self] in
            self?.dismiss(animated: true) {
                self?.onTap(.invite)
            }
        }).disposed(by: disposeBag)
        return v
    }()
    
    lazy var muteAllButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setTitle("全员静音".innerLocalized(), for: .normal)
        v.setTitle("解除全员静音".innerLocalized(), for: .selected)
        v.titleLabel?.font = .f14
        v.layer.borderColor = UIColor.systemGray3.cgColor
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 6
        v.setTitleColor(.systemBlue, for: .normal)
        v.rx.tap.throttle(.seconds(2), scheduler: MainScheduler.instance).subscribe (onNext: { [weak self] in
            v.isSelected = !v.isSelected
            self?.onTap(.muteAll(v.isSelected))
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    /*
    lazy var unMuteAllButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setTitle("解除全员静音".innerLocalized(), for: .normal)
        v.titleLabel?.font = .f14
        v.layer.borderColor = UIColor.systemGray3.cgColor
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 6
        v.setTitleColor(.systemBlue, for: .normal)
        v.rx.tap.throttle(.seconds(2), scheduler: MainScheduler.instance).subscribe (onNext: { [weak self] in
            self?.onTap(.muteAll(false))
        }).disposed(by: disposeBag)
        
        return v
    }()
    */
    lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(LiveMemberListCell.self, forCellReuseIdentifier: NSStringFromClass(LiveMemberListCell.self))
        v.separatorColor = .systemGray6
        v.rowHeight = UITableView.automaticDimension
        v.estimatedRowHeight = 50
        v.isScrollEnabled = false
        v.dataSource = self
        v.delegate = self
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cellBackgroundColor
        navigationItem.title = "成员".innerLocalized()
        let rightItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(handleClose))
        navigationItem.rightBarButtonItem = rightItem
        
        setupSubviews()
    }
    
    @objc
    private func handleClose() {
        dismiss(animated: true)
    }
    
    private func setupSubviews() {
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
        }
        
        let horSV = UIStackView(arrangedSubviews: [inviteButton, muteAllButton/*, unMuteAllButton*/])
        horSV.distribution = .fillEqually
        horSV.spacing = 8
        
        view.addSubview(horSV)
        horSV.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }
    
    func popOperationView(isPinged: Bool = false, isAllSeeHim: Bool = false, sender: UIView) {
        let item1 = PopoverTableViewController.MenuItem(title: isAllSeeHim ? "取消看他".innerLocalized() : "全部看他".innerLocalized(), icon: nil) { [self] in
            participantDidOperated?(self.selectedIndexPath!.row, .allSeeHim(!isAllSeeHim))
        }
        
        let item2 = PopoverTableViewController.MenuItem(title: isPinged ? "取消置顶".innerLocalized() : "置顶该员".innerLocalized(), icon: nil) { [self] in
            participantDidOperated?(self.selectedIndexPath!.row, .pined(!isPinged))
        }
        
        let popover = PopoverTableViewController(items: [item1, item2])
        popover.itemSize = CGSize(width: 117.w, height: 40)
        popover.show(in: self, sender: sender, permittedArrowDirections: .up)
    }
}

extension LiveMemberListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfitems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LiveMemberListCell.self), for: indexPath) as! LiveMemberListCell
        
        let p = participantForRowAt(indexPath.row)
        guard let p = p else { return cell }
        
        let participant = p.participant
    
        let isPined = p.isPinged
        let allSeeHim = p.isAllSeeHim
        let showOperate = p.showOperate
        
        cell.pinedImageView.isHidden = !isPined
        cell.participant = participant
        cell.audioButton.isHidden = !showOperate
        cell.videoButton.isHidden = !showOperate
        cell.moreButton.isHidden = !showOperate
        
        cell.onTap = { [weak self, weak cell] (ac: LiveMemberOperate) in
            guard let `self` = self else { return }
            self.selectedIndexPath = indexPath
            
            switch ac {
            case .more:
                popOperationView(isPinged: isPined, isAllSeeHim: allSeeHim, sender: cell!.moreButton)
                break
            default:
                self.participantDidOperated?(indexPath.row, ac)
            }
        }
        return cell
    }
}

class LiveMemberListCell: UITableViewCell {
    
    let disposeBag = DisposeBag()
    
    lazy var avatarView: AvatarView = {
        let v = AvatarView()
        
        return v
    }()
    
    lazy var nameLabel: UILabel = {
        let v = UILabel()
        
        return v
    }()
    
    lazy var pinedImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(nameInBundle: "live_room_pined_icon")
        
        return v
    }()
    
    // 静音按钮
    lazy var audioButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "live_room_audio_grey_on_icon"), for: .normal)
        v.setImage(UIImage(nameInBundle: "live_room_audio_grey_off_icon"), for: .selected)
        v.rx.tap.throttle(.seconds(2), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.onTap?(.audio(!v.isSelected))
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    // 开启视频
    lazy var videoButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "live_room_video_grey_on_icon"), for: .normal)
        v.setImage(UIImage(nameInBundle: "live_room_video_grey_off_icon"), for: .selected)
        v.rx.tap.throttle(.seconds(2), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.onTap?(.video(!v.isSelected))
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    lazy var moreButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "live_room_more_icon"), for: .normal)
        v.tintColor = .systemGray3
        v.rx.tap.throttle(.seconds(2), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.onTap?(.more)
        }).disposed(by: disposeBag)
        return v
    }()
    
    var onTap: ((_ operate: LiveMemberOperate) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let horSV = UIStackView(arrangedSubviews: [avatarView, nameLabel, audioButton, videoButton/*, moreButton*/])
        horSV.spacing = 16
        horSV.alignment = .center
        horSV.distribution = .fill
        
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        audioButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        videoButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        moreButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        avatarView.snp.makeConstraints { make in
            make.size.equalTo(42)
        }
        
        contentView.addSubview(horSV)
        horSV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        contentView.addSubview(pinedImageView)
        pinedImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public weak var participant: Participant? {
        didSet {
            if let oldValue {
                oldValue.remove(delegate: self)
            }
            
            if let participant {
                participant.add(delegate: self)

                nameLabel.text = participant.showName
                avatarView.setAvatar(url: participant.faceURL, text: participant.showName)
                isVideoEnable = participant.isCameraEnabled() || participant.isScreenShareEnabled()
                isMicEnable = participant.isMicrophoneEnabled()
            }
        }
    }
    
    private var isMicEnable: Bool = true {
        didSet {
            audioButton.isSelected = !isMicEnable
        }
    }
    
    private var isVideoEnable: Bool = true {
        didSet {
            videoButton.isSelected = !isVideoEnable
        }
    }
}

extension LiveMemberListCell: ParticipantDelegate {
    public func participant(_ participant: Participant, trackPublication publication: TrackPublication, didUpdateIsMuted muted: Bool) {
        print("\(#function) \(String(describing: participant.showName)) - \(publication.kind) status:\(!muted)")
        DispatchQueue.main.async { [weak self] in
            if publication.kind == .audio {
                self?.isMicEnable = !muted
            } else {
                self?.isVideoEnable = !muted
            }
        }
    }
}
