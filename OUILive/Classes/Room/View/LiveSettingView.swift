import SnapKit
import RxSwift
import OUICore

enum LiveSettingType: CaseIterable {
    static var allCases: [LiveSettingType] = []
    
    case participantCanUnmuteSelf(Bool)       //成员是否能自己解除禁言
    case participantCanEnableVideo(Bool)  //成员是否能开启视频
    case onlyHostShareScreen(Bool)        //仅主持人可共享屏幕
    case onlyHostInviteUser(Bool)         //仅主持人可邀请用户
    case joinDisableMicrophone(Bool)      //加入是否默认关麦克风
    
    var title: String {
        switch self {
        case .participantCanUnmuteSelf:
            return "允许成员自我解除静音".innerLocalized()
        case .participantCanEnableVideo:
            return "允许成员开启视频".innerLocalized()
        case .onlyHostShareScreen:
            return "仅主持人可以分享屏幕".innerLocalized()
        case .onlyHostInviteUser:
            return "仅主持人可邀请会议成员".innerLocalized()
        case .joinDisableMicrophone:
            return "成员入会静音".innerLocalized()
        }
    }
}

class LiveSettingView: UIView {
    
    let disposeBag = DisposeBag()
    var onCompletion: ((SettingInfo) -> Void)!
    var onTap: (() -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.text = "会议设置".innerLocalized()
        v.textColor = .black
        return v
    }()
    
    private lazy var completionButton: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("确定".innerLocalized(), for: .normal)
        
        v.rx.tap.subscribe (onNext: { [weak self] in
            guard let self else { return }
            let info = SettingInfo()
            info.roomID = settingInfo.roomID
            info.participantCanUnmuteSelf = settingInfo.participantCanUnmuteSelf
            info.participantCanEnableVideo = settingInfo.participantCanEnableVideo
            info.onlyHostShareScreen = settingInfo.onlyHostShareScreen
            info.onlyHostInviteUser = settingInfo.onlyHostInviteUser
            info.joinDisableMicrophone = settingInfo.joinDisableMicrophone
            
            onCompletion?(info)
        }).disposed(by: disposeBag)
      
        return v
    }()
    
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(LiveSwitchCell.self, forCellReuseIdentifier: NSStringFromClass(LiveSwitchCell.self))
        v.separatorColor = .systemGray6
        v.rowHeight = 48
        v.isScrollEnabled = false
        v.delegate = self
        v.dataSource = self
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .cellBackgroundColor

        return v
    }()
    
    init(onCompletion: @escaping ((SettingInfo) -> Void)) {
        super.init(frame: .zero)
        self.onCompletion = onCompletion
        backgroundColor = .clear
        
        let tap = UITapGestureRecognizer()
        addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.onTap?()
        }).disposed(by: disposeBag)
        
        // 被点穿了，简单的阻止下
        let tap2 = UITapGestureRecognizer()
        contentView.addGestureRecognizer(tap2)
        tap2.rx.event.subscribe(onNext: { [weak self] _ in
        }).disposed(by: disposeBag)
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
        }
        
        contentView.addSubview(completionButton)
        completionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(12)
        }
        
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(completionButton.snp.bottom).offset(18)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addRoundedCorners(corners: [.topLeft, .topRight], radius: 14)
    }
    
    var settingInfo: SettingInfo! {
        didSet {
            LiveSettingType.allCases = [.participantCanUnmuteSelf(settingInfo.participantCanUnmuteSelf ?? false),
                                        .participantCanEnableVideo(settingInfo.participantCanEnableVideo ?? false),
                                        .onlyHostShareScreen(settingInfo.onlyHostShareScreen ?? false),
                                        .onlyHostInviteUser(settingInfo.onlyHostInviteUser ?? false),
                                        .joinDisableMicrophone(settingInfo.joinDisableMicrophone ?? false)]
            tableView.reloadData()
        }
    }
}

extension LiveSettingView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingInfo != nil ? LiveSettingType.allCases.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LiveSwitchCell.self), for: indexPath) as! LiveSwitchCell
        
        cell.leadingLabel.text = LiveSettingType.allCases[indexPath.row].title
        let type = LiveSettingType.allCases[indexPath.row]
        switch type {
        case .participantCanUnmuteSelf(let value):
            cell.trailingSwitch.isOn = value
            cell.onSwitch = {[weak self] isOn in
                self?.settingInfo.participantCanUnmuteSelf = isOn
            }
        case .participantCanEnableVideo(let value):
            cell.trailingSwitch.isOn = value
            cell.onSwitch = {[weak self] isOn in
                self?.settingInfo.participantCanEnableVideo = isOn
            }
        case .onlyHostShareScreen(let value):
            cell.trailingSwitch.isOn = value
            cell.onSwitch = {[weak self] isOn in
                self?.settingInfo.onlyHostShareScreen = isOn
            }
        case .onlyHostInviteUser(let value):
            cell.trailingSwitch.isOn = value
            cell.onSwitch = {[weak self] isOn in
                self?.settingInfo.onlyHostInviteUser = isOn
            }
        case .joinDisableMicrophone(let value):
            cell.trailingSwitch.isOn = value
            cell.onSwitch = {[weak self] isOn in
                self?.settingInfo.joinDisableMicrophone = isOn
            }
        }
        
        return cell
    }
}

class LiveSwitchCell: UITableViewCell {
    
    let disposeBag = DisposeBag()
    
    lazy var leadingLabel: UILabel = {
        let v = UILabel()
        
        return v
    }()
    
    lazy var trailingSwitch: UISwitch = {
        let v = UISwitch()
        v.rx.isOn
            .subscribe(onNext: { [weak self] isOn in
                print("Switch is now \(isOn ? "on" : "off")")
                self?.onSwitch?(isOn)
            })
            .disposed(by: disposeBag)
        return v
    }()
    
    var onSwitch: ((_ isOn: Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let horSV = UIStackView(arrangedSubviews: [leadingLabel, UIView(), trailingSwitch])
        horSV.alignment = .center
        
        contentView.addSubview(horSV)
        horSV.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
