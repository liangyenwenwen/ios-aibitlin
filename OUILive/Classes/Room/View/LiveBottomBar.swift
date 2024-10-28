
import RxSwift
import SnapKit
import RxCocoa
import OUICore
import AVFAudio

enum LiveBottomBarAction {
    case mute   // 静音
    case video  // 视频
    case screenShare // 共享屏幕
    case member // 成员
    case setting// 设置
}


class LiveBottomBar: UIView {
    let disposeBag = DisposeBag()
    
    private let bgColor = UIColor(red: 34 / 255.0, green: 34 / 255.0, blue: 34 / 255.0, alpha: 1)
    private var audioPlayer: AVAudioPlayer?

    // 静音按钮
    private lazy var audioButton: UIButton = {
        let v = LayoutButton(imagePosition: .top)
        
        v.setTitle("meetingMute".innerLocalized(), for: .normal)
        v.setTitle("meetingUnmute".innerLocalized(), for: .selected)
        v.setTitle("meetingMute".innerLocalized(), for: .disabled)
        v.setFont(.systemFont(ofSize: 10))
        
        v.setImage(UIImage(nameInBundle: "live_room_audio_on_icon"), for: .normal)
        v.setImage(UIImage(nameInBundle: "live_room_audio_off_icon"), for: .selected)
        v.setImage(UIImage(nameInBundle: "live_room_audio_off_icon"), for: [.disabled, .selected])
        
        v.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            // 房主允许私自解除静音
            if onTap?(.mute) == true {
                let path =
                audioTurnOn = !audioTurnOn
                v.isSelected = audioTurnOn
                playMusic(name: "meeting_mic_turn_on")
            } else {
                // 如果房主不允许私自解除禁音，本地只能关闭
                if audioTurnOn {
                    audioTurnOn = !audioTurnOn
                    v.isSelected = !audioTurnOn
                    playMusic(name: "meeting_mic_turn_off")
                }
            }
            
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    private func playMusic(name: String) {
        if let bundle = ViewControllerFactory.getBundle(), let path = bundle.path(forResource: name, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error: Could not load audio file")
            }
        }
    }
    
    // 开启视频
    private lazy var videoButton: UIButton = {
        let v = LayoutButton(imagePosition: .top)

        v.setTitle("meetingCloseVideo".innerLocalized(), for: .normal)
        v.setTitle("meetingOpenVideo".innerLocalized(), for: .selected)
        v.setTitle("meetingCloseVideo".innerLocalized(), for: .disabled)

        v.titleLabel?.font = .systemFont(ofSize: 10)
        
        v.setImage(UIImage(nameInBundle: "live_room_video_on_icon"), for: .normal)
        v.setImage(UIImage(nameInBundle: "live_room_video_off_icon"), for: .selected)
        v.setImage(UIImage(nameInBundle: "live_room_video_off_icon"), for: .disabled)

        v.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            // 房主允许开启视频
            if onTap?(.video) == true {
                videoTurnOn = !videoTurnOn
                v.isSelected = videoTurnOn
            } else {
                if videoTurnOn {
                    videoTurnOn = !videoTurnOn
                    v.isSelected = !videoTurnOn
                }
            }
            
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    // 开启屏幕共享
    private lazy var screenShareButton: UIButton = {
        let v = LayoutButton(imagePosition: .top)

        v.setTitle("屏幕共享".innerLocalized(), for: .normal)
        v.setTitle("屏幕共享".innerLocalized(), for: .selected)
        v.titleLabel?.font = .systemFont(ofSize: 10)
        
        v.setImage(UIImage(nameInBundle: "live_room_screen_share_icon"), for: .normal)
        v.setImage(UIImage(nameInBundle: "live_room_screen_share_icon"), for: .selected)
        v.setImage(UIImage(nameInBundle: "live_room_screen_share_icon"), for: .disabled)

        v.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            v.backgroundColor = .clear
            // 房主允许屏幕共享
            if onTap?(.screenShare) == true {
                screenShareTurnOn = !screenShareTurnOn
                v.isSelected = screenShareTurnOn
            } else {
                if screenShareTurnOn {
                    screenShareTurnOn = !screenShareTurnOn
                    v.isSelected = !screenShareTurnOn
                }
            }
            
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    // 成员按钮
    private lazy var memberButton: UIButton = {
        let v = LayoutButton(imagePosition: .top)
        
        v.setImage(UIImage(nameInBundle: "live_room_member_icon"), for: .normal)
        v.titleLabel?.font = .systemFont(ofSize: 10)
        v.setTitle("成员(0)".innerLocalized(), for: .normal)

        v.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.onTap?(.member)
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    // 设置按钮
    private lazy var settingButton: UIButton = {
        let v = LayoutButton(imagePosition: .top)
        v.setImage(UIImage(nameInBundle: "live_room_setting_icon"), for: .normal)
        
        v.setTitle("设置".innerLocalized(), for: .normal)
        v.titleLabel?.font = .systemFont(ofSize: 10)
        
        v.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.onTap?(.setting)
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    var audioTurnOn: Bool = false
    var videoTurnOn: Bool = false
    var screenShareTurnOn: Bool = false
    
    var onTap: ((_ action: LiveBottomBarAction) -> Bool)?
    
    var memberCount: Int = 0 {
        didSet {
            DispatchQueue.main.async { [self] in
                self.memberButton.setTitle("成员".innerLocalized() + "(\(self.memberCount))", for: .normal)
            }
        }
    }
    
    // 更新按钮是否可响应
    func updateButtonStatus(audio: Bool? = nil, audioIsEnable: Bool? = nil, video: Bool? = nil, videoIsEnable: Bool? = nil, screenShare: Bool? = nil, screenShareIsEnable: Bool? = nil, setting: Bool? = nil) {
        DispatchQueue.main.async { [self] in
            if let audio {
                audioButton.isSelected = !audio
                audioTurnOn = audio
            }
            if let audioIsEnable {
                audioButton.isEnabled = audioIsEnable
                audioButton.alpha = audioIsEnable ? 1.0 : 0.25
            }
            
            if let video {
                videoButton.isSelected = !video
                videoTurnOn = video
            }
            if let videoIsEnable {
                videoButton.isEnabled = videoIsEnable
            }
            
            if let screenShare {
                screenShareButton.isSelected = !screenShare
                screenShareTurnOn = screenShare
            }
            
            if let screenShareIsEnable {
                screenShareButton.isEnabled = screenShareIsEnable
            }
            
            if let setting {
                settingButton.isHidden = !setting
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = bgColor
        
        let horSV = UIStackView(arrangedSubviews: [audioButton, videoButton, screenShareButton, memberButton, settingButton])
        horSV.distribution = .fillEqually
        audioButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        videoButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        screenShareButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        memberButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        settingButton.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
//        audioButton.titleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height ,-btn.imageView.frame.size.width, 0.0,0.0)];
//        [audioButton setImageEdgeInsets:UIEdgeInsetsMake(-btn.titleLabel.bounds.size.height,(btn.frame.size.width-btn.imageView.bounds.size.width)/2.0,0.0,(btn.frame.size.width-btn.imageView.bounds.size.width)/2.0)];
        
        addSubview(horSV)
        horSV.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(64)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
