
import OUICore
import SnapKit

class MomentNavBar: UIView {
    
    var onClick: ((_ sender: UIButton)->Void)?
    
    lazy var navBarView: UIView = {
        let v = UIView(frame: bounds)
        v.backgroundColor = UIColor(red: 239, green: 239, blue: 239, alpha: 1.0)
        v.alpha = 0
        return v
    }()
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.text = "朋友圈".innerLocalized()
        v.alpha = 0
        v.font = UIFont.boldSystemFont(ofSize: 17)
        v.textAlignment = .center
        return v
    }()
    
    lazy var backBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "moments_arrow_wihte_left"), for: .normal)
        v.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
        v.tag = 100

        return v
    }()
    
    lazy var publishBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "moments_publish_icon"), for: .normal)
        v.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
        v.tag = 200
        return v
    }()
    
    lazy var newMsgBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(nameInBundle: "moments_new_msg_icon"), for: .normal)
        v.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
        v.tag = 300
        return v
    }()
    
    var isScrollUp: Bool = false {
        didSet {
            let backImage = isScrollUp ? "moments_arrow_black_left" : "moments_arrow_wihte_left"
            let newMsgImage = isScrollUp ? "moments_new_msg_black_icon" : "moments_new_msg_icon"
            let publishImage = isScrollUp ? "moments_publish_black_icon" : "moments_publish_icon"
            
            backBtn.setImage(UIImage(nameInBundle: backImage), for: .normal)
            newMsgBtn.setImage(UIImage(nameInBundle: newMsgImage), for: .normal)
            publishBtn.setImage(UIImage(nameInBundle: publishImage), for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {

        addSubview(navBarView)
        addSubview(titleLabel)
        addSubview(backBtn)
        addSubview(publishBtn)
        addSubview(newMsgBtn)
        
        navBarView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview().offset(16)
            make.size.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn)
        }
        
        newMsgBtn.snp.makeConstraints { make in
            make.trailing.equalTo(publishBtn.snp.leading).offset(-16)
            make.centerY.equalTo(backBtn)
            make.size.equalTo(40)
        }
        
        publishBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(backBtn)
            make.size.equalTo(40)
        }
    }
    
    @objc func clickAction(_ btn: UIButton) {
        onClick?(btn)
    }
}
