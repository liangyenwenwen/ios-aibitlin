
import RxDataSources
import RxSwift
import OUICore
import ProgressHUD
import OUICalling

public class LiveRecordsViewController: UIViewController {
    private let _disposeBag = DisposeBag()
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _viewModel.getRecords()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "视频会议".innerLocalized()
        initView()
        bindData()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .darkContent
    }
    
    deinit {
        hidesBottomBarWhenPushed = false
    }

    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(LiveRecordCell.self, forCellReuseIdentifier: LiveRecordCell.className)
        v.rowHeight = UITableView.automaticDimension
        
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()

    lazy var joinBtn: UIStackView = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "live_room_add_meeting_icon"), for: .normal)
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            let vc = NewLiveViewController(operateType: .join)
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: _disposeBag)
        
        let v2 = UIButton(type: .custom)
        v2.setTitleColor(.label, for: .normal)
        v2.setTitle("加入会议".innerLocalized(), for: .normal)
        v2.titleLabel?.font = .f12
        
        let verSV = UIStackView(arrangedSubviews: [v, v2])
        verSV.axis = .vertical
        
        return verSV
    }()

    lazy var fastBtn: UIStackView = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "live_room_fast_meeting_icon"), for: .normal)
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            
            if CallingManager.isBusy || LiveRoomViewController.isBusy {
                presentAlert(title: "callingBusy".innerLocalized())
                
                return
            }
            
            ProgressHUD.animate()
            self._viewModel.createMeeting { [weak self] invitaion in
                ProgressHUD.dismiss()
                guard let self else { return }
                LiveRoomViewController.showIn(viewController: self, invitationInfo: invitaion)
            }
        }).disposed(by: _disposeBag)
        
        let v2 = UIButton(type: .custom)
        v2.setTitleColor(.label, for: .normal)
        v2.setTitle("快速会议".innerLocalized(), for: .normal)
        v2.titleLabel?.font = .f12
        
        let verSV = UIStackView(arrangedSubviews: [v, v2])
        verSV.axis = .vertical
        
        return verSV
    }()
    
    lazy var bookingBtn: UIStackView = {

        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "live_room_fast_meeting_icon"), for: .normal)
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            let vc = NewLiveViewController(operateType: .booking)
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: _disposeBag)
        
        let v2 = UIButton(type: .custom)
        v2.setTitleColor(.label, for: .normal)
        v2.setTitle("预约会议".innerLocalized(), for: .normal)
        v2.titleLabel?.font = .f12
        let verSV = UIStackView(arrangedSubviews: [v, v2])
        verSV.axis = .vertical
        
        return verSV
    }()

    private func initView() {
        view.backgroundColor = .systemBackground
        
        let btnStackView: UIStackView = {
            let v = UIStackView(arrangedSubviews: [joinBtn, fastBtn, bookingBtn])
            v.distribution = .equalCentering
            return v
        }()
        
        view.addSubview(btnStackView)
        btnStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(btnStackView.snp.bottom)
        }
    }

    private let _viewModel = LiveRecordsViewModel()

    private func bindData() {
        _viewModel.items.bind(to: tableView.rx.items(cellIdentifier: LiveRecordCell.className, cellType: LiveRecordCell.self)) { _, model, cell in
            cell.selectionStyle = .none
            
            cell.titleLabel.text = model.meetingName
            cell.dateTimeLabel.text = "\(Date.timeString(timeInterval: model.startTime * 1000)) - \(Date.timeString(timeInterval: model.endTime * 1000))"
            cell.sponsorLabel.text = "发起人：".innerLocalized() + (model.hostUserName ?? "")
            
            let beginDate = Date.timeString(timeInterval: model.startTime * 1000)
            let endItems = Date.timeString(timeInterval: model.endTime * 1000).split(separator: " ")
            cell.dateTimeLabel.text = "\(beginDate) - \(endItems.last ?? "")"
            
            let now = Date().timeIntervalSince1970
            
            if now > model.endTime {
                cell.accessoryType = .none
                cell.statusLabel.text = " " + "已结束".innerLocalized() + " "
            } else if now < model.startTime {
                cell.statusLabel.text = " " + "未开始".innerLocalized() + " "
                cell.statusLabel.backgroundColor = .systemBlue
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.statusLabel.text = " " + "已开始".innerLocalized() + " "
                cell.statusLabel.backgroundColor = .systemOrange
            }
        }.disposed(by: _disposeBag)

        tableView.rx.modelSelected(MeetingInfo.self).subscribe(onNext: { [weak self] (record: MeetingInfo) in
            let vc = NewLiveDetailViewController(meetingInfo: record)
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: _disposeBag)
    }
        
    private func startMeeting(meeting: MeetingInfo) {
        ProgressHUD.animate()
        _viewModel.joinMeeting(meetingID: meeting.roomID) { [weak self] invitaion in
            ProgressHUD.dismiss()
            guard let self else { return }
            LiveRoomViewController.showIn(viewController: self, invitationInfo: invitaion)
            
        } onFailure: { errCode, errMsg in
            ProgressHUD.dismiss()
            if errMsg?.contains("roomIsNotExist") == true {
//                ProgressHUD.error("会议已经结束！".innerLocalized())
                if let handler = OIMApi.showTipHandle {
                                
                    handler("会议已经结束！".innerLocalized(), { res in
                       
                    })
                }
            } else {
//                ProgressHUD.error("网络异常请稍后再试！".innerLocalized())
                if let handler = OIMApi.showTipHandle {
                                
                    handler("网络异常请稍后再试！".innerLocalized(), { res in
                       
                    })
                }
            }
        }
    }
}

class LiveRecordCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        
        return v
    }()
    
    let statusLabel: UILabel = {
        let v = UILabel()
        v.font = .f12
        v.textColor = .white
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 5
        
        return v
    }()
    
    let dateTimeLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .systemGray2
        return v
    }()
    
    // 发起人
    let sponsorLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .systemGray2

        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let titleRow = UIStackView(arrangedSubviews: [titleLabel, statusLabel])
        titleRow.spacing = 8
        let subTitleRow = UIStackView(arrangedSubviews: [dateTimeLabel, sponsorLabel])
        subTitleRow.spacing = 8
        
        let infoColum = UIStackView(arrangedSubviews: [titleRow, subTitleRow])
        infoColum.axis = .vertical
        infoColum.spacing = 8
        infoColum.alignment = .leading
        infoColum.distribution = .equalSpacing
        
        contentView.addSubview(infoColum)
        infoColum.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
    }
}
