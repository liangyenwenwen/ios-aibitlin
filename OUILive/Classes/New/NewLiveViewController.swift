
import OUICore
import RxSwift
import SnapKit
import RxCocoa
import OUICalling
import ProgressHUD

public enum OperateType {
    case join
    case booking
    case modify
}

public class NewLiveViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    lazy var inputTextFiled: UITextField = {
        let v = UITextField()
        
        return v
    }()
    
    lazy var joinButton: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("进入会议".innerLocalized(), for: .normal)
        v.backgroundColor = .systemBlue
        v.setTitleColor(.white, for: .normal)
        v.layer.cornerRadius = 6
        v.isEnabled = false
        return v
    }()
    
    lazy var beginValueLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        return v
    }()
    
    lazy var durationValueLabel: UILabel = {
        let v = UILabel()
        
        return v
    }()
    
    var operateType: OperateType = .booking
    var meetingInfo: MeetingInfo?
    let viewModel = NewLiveViewModel()
    var compeletion: ((MeetingInfo) -> Void)?
    
    public init(operateType: OperateType = .booking, meetingInfo: MeetingInfo? = nil, compeletion: ((MeetingInfo) -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.operateType = operateType
        self.meetingInfo = meetingInfo
        if let m = meetingInfo {
            viewModel.name = m.meetingName ?? ""
            viewModel.meetingID = m.roomID
            viewModel.beginTime = m.startTime
            viewModel.duration = m.endTime - m.startTime
            self.compeletion = compeletion
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        
        if operateType == .booking {
            newLiveView()
            navigationItem.title = "发起会议".innerLocalized()
            joinButton.setTitle("预约会议".innerLocalized(), for: .normal)
            joinButton.rx.tap.subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
                ProgressHUD.animate()
                self?.viewModel.createMeeting({ info in
                    ProgressHUD.dismiss()
                    guard let `self` = self else { return }
                    let m = MeetingInfo()
                    m.meetingName = self.viewModel.name
                    m.hostUserID = IMController.shared.uid
                    m.startTime = self.viewModel.beginTime
                    m.endTime = self.viewModel.beginTime + self.viewModel.duration
                    m.roomID = info.roomID ?? ""
                    
                    let vc = NewLiveDetailViewController(meetingInfo: m)
                    self.navigationController?.pushViewController(vc, animated: true)
                }, onFailure: { (errCode, errMsg) in
                    ProgressHUD.dismiss()
//                    ProgressHUD.error(errMsg)
                    
                    if let handler = OIMApi.showTipHandle {
                                    
                        handler("网络异常请稍后再试！".innerLocalized(), { res in
                           
                        })
                    }
                })
            }).disposed(by: disposeBag)
        } else if operateType == .modify {
            newLiveView()
            navigationItem.title = "修改会议信息".innerLocalized()
            joinButton.setTitle("确认修改".innerLocalized(), for: .normal)
            joinButton.rx.tap.subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                ProgressHUD.animate()
                self.viewModel.updateMeetingInfo(meetingInfo: self.meetingInfo!, completion: { [weak self] r in
                    ProgressHUD.dismiss()
                    if r != nil {
                        self?.compeletion?(r!)
                        self?.navigationController?.popViewController(animated: true)
                    }
                })
            }).disposed(by: disposeBag)
        } else {
            joinLiveView()
            joinButton.rx.tap.subscribe(onNext: { [weak self] in
                self?.view.endEditing(true)
                
                if CallingManager.isBusy || LiveRoomViewController.isBusy {
                    self?.presentAlert(title: "callingBusy".innerLocalized())

                    return
                }
                ProgressHUD.animate()
                self?.viewModel.joinMeeting({ [weak self] invitaion in
                    ProgressHUD.dismiss()
                    guard let self else { return }
                    LiveRoomViewController.showIn(viewController: self, invitationInfo: invitaion)
                    
                }, onFailure: { (errCode, errMsg) in
                    ProgressHUD.dismiss()
                    if errMsg?.contains("roomIsNotExist") == true {
//                        ProgressHUD.error("会议已经结束！".innerLocalized())
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
                })
            }).disposed(by: disposeBag)
        }
        
        view.addSubview(joinButton)
        joinButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(230)
            make.height.equalTo(44)
        }
    }
}

// 创建/修改会议室
extension NewLiveViewController {
    func newLiveView() {
        let container = UIView()
        container.backgroundColor = .cellBackgroundColor
        view.addSubview(container)
        
        container.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
        }
        
        let nameTextField = UITextField()
        nameTextField.placeholder = "请输入会议主题".innerLocalized()
        nameTextField.text = viewModel.name
        nameTextField.rx.text.orEmpty.changed.subscribe(onNext: { [weak self] text in
            guard let `self` = self else { return }
            self.viewModel.name = text
            self.changeCompletionButtonStatus()
        }).disposed(by: disposeBag)
        nameTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        let beginLabel = UILabel()
        beginLabel.text = "开始时间".innerLocalized()
        if viewModel.beginTime != 0 {
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm"
            beginValueLabel.text = format.string(from: Date(timeIntervalSince1970: self.viewModel.beginTime))
        }
        let beginArrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        beginArrow.tintColor = .systemGray3
        beginArrow.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let durationLabel = UILabel()
        durationLabel.text = "会议时长".innerLocalized()
        durationValueLabel.text = viewModel.duration == 0 ? nil : String(viewModel.duration / 3600) + "小时".innerLocalized()
        let durationArrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        durationArrow.tintColor = .systemGray3
        durationArrow.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let beginSV = UIStackView(arrangedSubviews: [beginLabel, beginValueLabel, beginArrow])
        beginSV.alignment = .center
        beginSV.isUserInteractionEnabled = true
        beginSV.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        let tap = UITapGestureRecognizer()
        beginSV.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.showDatePicker()
        }).disposed(by: disposeBag)
        
        let durationSV = UIStackView(arrangedSubviews: [durationLabel, durationValueLabel, durationArrow])
        durationSV.alignment = .center
        durationSV.isUserInteractionEnabled = true
        durationSV.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        
        let tap2 = UITapGestureRecognizer()
        durationSV.addGestureRecognizer(tap2)
        tap2.rx.event.subscribe(onNext: { [weak self] _ in
            self?.showDurationPicker()
        }).disposed(by: disposeBag)
        
        let verSV = UIStackView(arrangedSubviews: [nameTextField,
                                                   beginSV,
                                                   durationSV])
        verSV.axis = .vertical
        container.addSubview(verSV)
        
        verSV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
    }
    
    func showDatePicker() {
        view.endEditing(true)
        var date: Date = viewModel.beginTime == 0 ? Date() : NSDate(timeIntervalSince1970: viewModel.beginTime) as Date
    
        JNDatePickerView.show(onWindowOfView: view, currentDate: date) { (pickerView: JNDatePickerView) in
            pickerView.datePicker.maximumDate = Date(timeIntervalSinceNow: 604800) // 7天
            pickerView.datePicker.minimumDate = Date()
            pickerView.datePicker.datePickerMode = .dateAndTime
        } confirmAction: { [weak self] (selectedDate: Date) in
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm"
            let r = format.string(from: selectedDate)
            self?.beginValueLabel.text = r
            
            let timeStamp = selectedDate.timeIntervalSince1970
            self?.viewModel.beginTime = timeStamp
            
            self?.changeCompletionButtonStatus()
        }
    }
    
    func showDurationPicker() {
        let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(.init(title: "0.5" + "小时".innerLocalized(), style: .default, handler: { [weak self] acion in
            self?.selectedDuration(0.5)
        }))
        
        alertController.addAction(.init(title: "1" + "小时".innerLocalized(), style: .default, handler: { [weak self] acion in
            self?.selectedDuration(1)
        }))
        
        alertController.addAction(.init(title: "1.5" + "小时".innerLocalized(), style: .default, handler: { [weak self] acion in
            self?.selectedDuration(1.5)
        }))
        
        alertController.addAction(.init(title: "2" + "小时".innerLocalized(), style: .default, handler: { [weak self] acion in
            self?.selectedDuration(2)
        }))
        
        alertController.addAction(.init(title: "取消".innerLocalized(), style: .cancel))
        present(alertController, animated: true)
    }
    
    func selectedDuration(_ duration: Double)  {
        view.endEditing(true)
        viewModel.duration = duration * 3600
        durationValueLabel.text = "\(duration)" + "小时".innerLocalized()
        
        changeCompletionButtonStatus()
    }
    
    func changeCompletionButtonStatus(whileJoing: Bool = false) {
        if whileJoing {
            joinButton.isEnabled = viewModel.meetingID?.isEmpty == false
        } else {
            joinButton.isEnabled = !viewModel.name.isEmpty && viewModel.beginTime > 0 && viewModel.duration > 0
        }
    }
}

// 加入会议室
extension NewLiveViewController {
    func joinLiveView() {
        navigationItem.title = "加入会议".innerLocalized()
        
        let container = UIView()
        container.backgroundColor = .cellBackgroundColor
        view.addSubview(container)
        
        container.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
        }
        
        let meetingIDTextField = UITextField()
        meetingIDTextField.placeholder = "请输入会议号".innerLocalized()
        meetingIDTextField.rx.text.orEmpty.changed.subscribe(onNext: { [weak self] text in
            guard let `self` = self else { return }
            self.viewModel.meetingID = text
            self.changeCompletionButtonStatus(whileJoing: true)
        }).disposed(by: disposeBag)
        
        let meetingIDLabel = UILabel()
        meetingIDLabel.text = "会议号".innerLocalized()
        meetingIDLabel.font = .f17
        meetingIDLabel.textColor = .c0C1C33
        
        let IDStack = UIStackView(arrangedSubviews: [meetingIDLabel, meetingIDTextField])
        IDStack.spacing = 8
        
        meetingIDLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let nicknameTextField = UITextField()
        nicknameTextField.placeholder = "请输入您的名称".innerLocalized()
        nicknameTextField.text = viewModel.name
        nicknameTextField.rx.text.orEmpty.changed.subscribe(onNext: { [weak self] text in
            guard let `self` = self else { return }
            self.viewModel.name = text
            self.changeCompletionButtonStatus(whileJoing: true)
        }).disposed(by: disposeBag)
        
        let nicknameTipLabel = UILabel()
        nicknameTipLabel.text = "您的名称".innerLocalized()
        nicknameTipLabel.font = .f17
        nicknameTipLabel.textColor = .c0C1C33
        
        let nameStack = UIStackView(arrangedSubviews: [nicknameTipLabel, nicknameTextField])
        nameStack.spacing = 8
        
        let vStack = UIStackView(arrangedSubviews: [IDStack])
        vStack.spacing = 8
        vStack.axis = .vertical
        
        container.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        IDStack.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }
}
