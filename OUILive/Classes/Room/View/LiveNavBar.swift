import SnapKit
import RxSwift

enum LiveNavBarAction {
    case scale  // 缩放
    case earpiece(_ enable: Bool) // 听筒
    case info   // 基础信息
    case end    // 结束
}

class LiveNavBar: UIView {
    let disposeBag = DisposeBag()

    // 缩放按钮
    lazy var scaleButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "live_room_scale_icon"), for: .normal)
        
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.onTap?(.scale)
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    // 听筒按钮
    lazy var earpieceButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "live_room_loudspeaker_icon"), for: .normal)
        v.setImage(UIImage(nameInBundle: "live_room_earpiece_icon"), for: .selected)
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            v.isSelected = !v.isSelected
            self.onTap?(.earpiece(v.isSelected))
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    // 会议名称
    lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.isUserInteractionEnabled = true
        v.textColor = .white
        v.text = "loading".innerLocalized()
        
        let tap = UITapGestureRecognizer()
        v.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.onTap?(.info)
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    // 展开尖头
    lazy var arrowImageView: UIImageView = {
        let v = UIImageView()
        v.image = .init(systemName: "chevron.down")
        v.tintColor = .white
        v.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        v.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.onTap?(.info)
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    // 时长
    lazy var durationLabel: UILabel = {
        let v = UILabel()
        v.textColor = .white
        v.font = .systemFont(ofSize: 10)
        
        return v
    }()
    
    lazy var endButton: UIButton = {
        let v = UIButton(type: .custom)
        v.backgroundColor = .cFF381F
        v.setTitle("结束".innerLocalized(), for: .normal)
        v.layer.cornerRadius = 6
        v.setTitleColor(.white, for: .normal)
        
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.onTap?(.end)
        }).disposed(by: disposeBag)
        return v
    }()
    
    var onTap: ((_ action: LiveNavBarAction) -> Void)?
    // 展示时长
    var duration: Int = 0 {
        didSet {
            DispatchQueue.main.async { [self]
                let m = self.duration / 60
                let s = self.duration % 60
    
                var timeline = ""
    
                if m > 99 {
                    timeline = String(format: "%d:%02d", m, s)
                } else {
                    timeline = String(format: "%02d:%02d", m, s)
                }
                self.durationLabel.text = timeline
            }
        }
    }
    
    init(onTap: ((_: LiveNavBarAction) -> Void)? = nil) {
        super.init(frame: .zero)
        backgroundColor = .black
        
        let nameSV = UIStackView(arrangedSubviews: [nameLabel, arrowImageView])
        nameSV.spacing = 8
        let infoSV = UIStackView(arrangedSubviews: [nameSV, durationLabel])
        infoSV.axis = .vertical
        infoSV.spacing = 8
        infoSV.alignment = .center
        
        let horSV = UIStackView(arrangedSubviews: [scaleButton, earpieceButton, infoSV, UIView(), endButton])
        horSV.distribution = .fillProportionally
        horSV.alignment = .center
        addSubview(horSV)
        horSV.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        endButton.snp.makeConstraints { make in
            make.width.equalTo(54)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(120)
        }
        
        snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        self.onTap = onTap
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
