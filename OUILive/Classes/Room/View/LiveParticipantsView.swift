
import Foundation
import RxSwift
import SnapKit
import LiveKitClient

class LiveParticipantsView: UIView {
    
    let disposeBag = DisposeBag()
    
    lazy var expandImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(nameInBundle: "live_room_expand_arrow")
        
        return v
    }()
    
    lazy var contentView: LiveContentView = {
        let v = LiveContentView()
        
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .init(hex: 0x343434)
        
        let expandView = UIView()
        expandView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        expandView.addGestureRecognizer(tap)
        
        tap.rx.event.subscribe (onNext: { [weak self] _ in
            self?.rotateArrow()
        }).disposed(by: disposeBag)
        
        addSubview(expandView)
        expandView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(30)
        }
        
        expandView.addSubview(expandImageView)
        expandImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(expandView.snp.bottom)
            make.height.equalTo(110)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    func rotateArrow() {
        let r = expandImageView.transform == .identity
        
        UIView.animate(withDuration: 0.3) { [self] in
            self.expandImageView.transform = r ? CGAffineTransform(rotationAngle: M_PI) : .identity
        }
        
        contentView.snp.updateConstraints { make in
            make.height.equalTo(r ? 0 : 110)
        }
        
        UIView.animate(withDuration: 0.3,
                       animations: { [weak self] in
            self?.layoutIfNeeded()
        }, completion: { finished in
            
        })
    }
    
    func reloadParticipants() {
        DispatchQueue.main.async {
            self.contentView.reloadParticipants()
        }
    }
}

