import SnapKit
import RxSwift
import OUICore

class LiveRoomInfoView: UIView {
    
    let disposeBag = DisposeBag()
    
    lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 17)
        v.textColor = .init(red: 22 / 255, green: 25 / 255, blue: 28 / 255, alpha: 1)
        return v
    }()
    
    lazy var IDLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 14)
        v.textColor = .systemGray3
        return v
    }()
    
    lazy var copyButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(nameInBundle: "live_room_copy_icon"), for: .normal)
        v.rx.tap.subscribe( onNext: { [weak self] _ in
            self?.onTap?()
            
        }).disposed(by: disposeBag)
        return v
    }()
    
    lazy var hostLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c0C1C33
        return v
    }()
    
    lazy var beginLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c0C1C33
        return v
    }()
    
    lazy var durationLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c0C1C33
        return v
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .cellBackgroundColor

        return v
    }()
    
    var onTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(contentView)
        
        // 被点穿了，简单的阻止下
        let tap2 = UITapGestureRecognizer()
        addGestureRecognizer(tap2)
        tap2.rx.event.subscribe(onNext: { [weak self] _ in
        }).disposed(by: disposeBag)
        
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        
        let IDSV = UIStackView(arrangedSubviews: [IDLabel, copyButton, UIView()])
        IDSV.spacing = 8
        
        let verSV = UIStackView(arrangedSubviews: [nameLabel, IDSV, hostLabel, beginLabel, durationLabel])
        verSV.axis = .vertical
        verSV.spacing = 16
        
        contentView.addSubview(verSV)
        verSV.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addRoundedCorners(corners: [.topLeft, .topRight], radius: 14)
    }
}
