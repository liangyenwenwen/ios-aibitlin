//
//import OUICore
//import Alamofire
//
//class ChatListHeaderView: UIView {
//    
//    private var preConnectionStatus = ConnectionStatus.connected
//    private let reachabilityManager = NetworkReachabilityManager()
//    
//    let avatarImageView: AvatarView = {
//        let v = AvatarView()
//        return v
//    }()
//
//    let companyNameLabel: UILabel = {
//        let v = UILabel()
//        v.font = .systemFont(ofSize: 12)
//        v.textColor = .c0C1C33
//        return v
//    }()
//
//    let nameLabel: UILabel = {
//        let v = UILabel()
//        v.font = .f17
//        v.textColor = .c0C1C33
//        v.translatesAutoresizingMaskIntoConstraints = false
//        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
//        
//        return v
//    }()
//
//    let callBtn: UIButton = {
//        let v = UIButton()
//        v.setImage(UIImage(nameInBundle: "chat_call_btn_icon"), for: .normal)
//        return v
//    }()
//
//    let addBtn: UIButton = {
//        let v = UIButton()
//        v.setImage(UIImage(nameInBundle: "chat_add_btn_icon"), for: .normal)
//        return v
//    }()
//
//    lazy var searchBar: UISearchBar = {
//        let v = UISearchBar(frame: CGRectZero)
//        v.searchBarStyle = .minimal
//        v.placeholder = "search".innerLocalized()
//        v.searchTextField.isEnabled = false
//        return v
//    }()
//    
//    lazy var connectionIndicator: UIActivityIndicatorView = {
//        let v = UIActivityIndicatorView(style: .medium)
//        v.startAnimating()
//        
//        return v
//    }()
//    
//    lazy var errorImageView: UIImageView = {
//        let v = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
//        v.tintColor = .cFF381F
//        v.isHidden = true
//        
//        return v
//    }()
//    
//    lazy var connectionLabel: UILabel = {
//        let t = UILabel()
//        t.font = .f12
//        t.text = "连接中"
//        t.textColor = .c0089FF
//        
//        return t
//    }()
//    
//    // 链接状态view
//    lazy var connectionView: UIView = {
//        let t = UIView()
//        t.layer.masksToBounds = true
//        t.layer.cornerRadius = StandardUI.cornerRadius
//
//        t.backgroundColor = .c0089FF.withAlphaComponent(0.15)
//        let horSV = UIStackView.init(arrangedSubviews: [errorImageView, connectionIndicator, connectionLabel])
//        horSV.spacing = 4
//        horSV.alignment = .center
//        t.addSubview(horSV)
//        
//        horSV.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(8)
//            make.top.bottom.equalToSuperview()
//        }
//        
//        return t
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .tertiarySystemBackground
//        
//        addSubview(avatarImageView)
//        avatarImageView.isHidden = true
//        avatarImageView.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(16)
//        }
//        
//        addSubview(searchBar)
//        searchBar.snp.makeConstraints { make in
////            make.top.equalTo(avatarImageView.snp.bottom).offset(12.h)
////            make.top.equalToSuperview()
//            make.leading.trailing.equalToSuperview().inset(8)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(36.h)
//        }
//
////        let hStack: UIStackView = {
////            let v = UIStackView(arrangedSubviews: [nameLabel, connectionView, UIView()])
////            v.axis = .horizontal
////            v.spacing = 12
////            v.alignment = .center
////            return v
////        }()
////
////        addSubview(hStack)
////        hStack.snp.makeConstraints { make in
////            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
////            make.centerY.equalTo(avatarImageView)
////        }
////        
////        connectionView.snp.makeConstraints { make in
////            make.height.equalTo(25)
////        }
//
//        let btnStack: UIStackView = {
//            let v = UIStackView(arrangedSubviews: [addBtn])
////            let v = UIStackView(arrangedSubviews: [callBtn, addBtn])
////            callBtn.snp.makeConstraints { make in
////                make.size.equalTo(28.w)
////            }
//            addBtn.snp.makeConstraints { make in
//                make.size.equalTo(28.w)
//            }
//            v.axis = .horizontal
//            v.distribution = .equalSpacing
//            v.spacing = 16
//            return v
//        }()
//        addSubview(btnStack)
//        btnStack.snp.makeConstraints { make in
//            make.leading.equalTo(hStack.snp.trailing).offset(8)
//            make.centerY.equalTo(avatarImageView)
//            make.trailing.equalToSuperview().offset(-16)
//        }
//        
//        snp.makeConstraints { make in
//            make.height.equalTo(kStatusBarHeight + 76.h)
//        }
////        startListening()
//    }
//
//    @available(*, unavailable)
//    required init?(coder _: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func startListening() {
//        // 监听网络状态变化
//        reachabilityManager?.startListening()
//        reachabilityManager?.listener = { [weak self] status in
//            switch status {
//            case .notReachable:
//                self?.setConnectIndicator(status: .connectFailure, failure: true)
//                self?.showConnectionView(true, showIndicator: false)
//            default:
//                break
//            }
//        }
//    }
//    
//    private func showConnectionView(_ show: Bool, showIndicator: Bool = false) {
//        showIndicator ? connectionIndicator.startAnimating() : connectionIndicator.stopAnimating()
//        
//        UIView.animate(withDuration: 0.3, animations: {[weak self] in
//            self?.connectionView.alpha = show ? 1.0 : 0
//        }, completion: { [weak self] _ in
//            self?.connectionView.isHidden = !show
//        })
//    }
//
//    func updateConnectionStatus(status: ConnectionStatus) {
//        guard reachabilityManager?.isReachable == true else { return }
//        // 如果状态发生变更，展示出来
//        showConnectionView(status != .syncComplete && status != .connected, showIndicator: true)
//        
//        if preConnectionStatus != status {
//            switch status {
//            case .connectFailure, .syncFailure:
//                setConnectIndicator(status: status, failure: true)
//            case .connecting, .connected, .syncStart, .syncComplete:
//                setConnectIndicator(status: status, failure: false)
//            case .kickedOffline:
//                break
//            }
//        }
//        preConnectionStatus = status
//    }
//    
//    private func setConnectIndicator(status: ConnectionStatus, failure: Bool) {
//        if failure {
//            connectionLabel.text = status.title
//            connectionLabel.textColor = .cFF381F
//            connectionIndicator.isHidden = true
//            errorImageView.isHidden = false
//            connectionView.backgroundColor = .c0089FF.withAlphaComponent(0.15)
//        } else {
//            connectionLabel.text = status.title
//            connectionLabel.textColor = .c0089FF
//            errorImageView.isHidden = true
//            connectionIndicator.isHidden = false
//            connectionView.backgroundColor = .c0089FF.withAlphaComponent(0.15)
//        }
//    }
//}


import OUICore
import Alamofire

class ChatListHeaderView: UIView {
    
    private var preConnectionStatus = ConnectionStatus.connected
    private let reachabilityManager = NetworkReachabilityManager()
    
    let avatarImageView: AvatarView = {
        let v = AvatarView()
        return v
    }()

    let companyNameLabel: UILabel = {
        let v = UILabel()
        v.font = .systemFont(ofSize: 12)
        v.textColor = .c0C1C33
        return v
    }()

    let nameLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return v
    }()

    let callBtn: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "chat_call_btn_icon"), for: .normal)
        return v
    }()

    let addBtn: UIButton = {
        let v = UIButton()
        v.setImage(UIImage(nameInBundle: "chat_add_btn_icon"), for: .normal)
        return v
    }()

//    lazy var searchBar: UISearchBar = {
//        let v = UISearchBar(frame: CGRectZero)
//        v.searchBarStyle = .minimal
//        v.placeholder = "search".innerLocalized()
//        v.searchTextField.isEnabled = false
//        v.clipsToBounds = true
//        v.layer.cornerRadius = 18
////        v.backgroundColor  = .init(hexString: "#F5F5F5")
//        v.searchTextField.backgroundColor =  .init(hexString: "#F5F5F5")
////        v.searchTextField.backgroundColor =  .red
//        return v
//    }()
    
//    lazy var searchView: UIView = {
//        let v = UIView()
//        v.backgroundColor = .init(hexString: "#F5F5F5")
//        v.clipsToBounds = true
//        v.layer.cornerRadius = 17.w
//        v.isUserInteractionEnabled = true
//        
//        let searchImg = UIImageView(image: UIImage(named: "search_gray"))
//        v.addSubview(searchImg)
//        searchImg.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(14.w)
//            make.width.height.equalTo(15.w)
//            make.centerY.equalToSuperview()
//        }
//        
//        let titleLbl = UILabel()
//        titleLbl.text = "search".innerLocalized()
//        titleLbl.font = UIFont(name: "PingFangSC-Regular", size: 13)
//        titleLbl.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
//        v.addSubview(titleLbl)
//        titleLbl.snp.makeConstraints { make in
//            make.left.equalToSuperview().offset(39.w)
//            make.centerY.equalToSuperview()
//        }
//        return v
//    }()
    
    lazy var connectionIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .medium)
        v.startAnimating()
        
        return v
    }()
    
    lazy var errorImageView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "exclamationmark.circle"))
        v.tintColor = .cFF381F
        v.isHidden = true
        
        return v
    }()
    
    lazy var titleLbl: UILabel = {
        let r = UILabel()
        r.text = "消息".localized()
        r.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        r.font = UIFont(name: "PingFangSC-Medium", size: 18)
        return r
    }()
    
    lazy var connectionLabel: UILabel = {
        let t = UILabel()
        t.font = .f12
        t.text = "连接中"
        t.textColor = .c0089FF
        
        return t
    }()
    
    // 链接状态view
    lazy var connectionView: UIView = {
        let t = UIView()
        t.layer.masksToBounds = true
        t.layer.cornerRadius = StandardUI.cornerRadius

        t.backgroundColor = .c0089FF.withAlphaComponent(0.15)
        let horSV = UIStackView.init(arrangedSubviews: [errorImageView, connectionIndicator, connectionLabel])
        horSV.spacing = 4
        horSV.alignment = .center
        t.addSubview(horSV)
        
        horSV.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview()
        }
        
        return t
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .tertiarySystemBackground
        
        addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            make.centerY.equalTo(avatarImageView)
            make.top.equalTo(kStatusBarHeight)
            make.height.equalTo(44)
            make.bottom.equalTo(0)
        }
        
        addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
        }
        avatarImageView.isHidden = true
        
//        addSubview(searchBar)
//        searchBar.snp.makeConstraints { make in
//            make.top.equalTo(avatarImageView.snp.bottom).offset(12.h)
//            make.top.equalTo(titleLbl.snp_bottom)
//            make.leading.trailing.equalToSuperview().inset(8)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(36.h)
//        }
        
//        addSubview(searchView)
//        searchView.snp.makeConstraints { make in
//            make.top.equalTo(titleLbl.snp_bottom)
//            make.leading.trailing.equalToSuperview().inset(16.w)
//            make.bottom.equalToSuperview()
//            make.height.equalTo(34.h)
//        }
        
        
        
        

//        let hStack: UIStackView = {
//            let v = UIStackView(arrangedSubviews: [nameLabel, connectionView, UIView()])
//            v.axis = .horizontal
//            v.spacing = 12
//            v.alignment = .center
//            return v
//        }()
//
//        addSubview(hStack)
//        hStack.snp.makeConstraints { make in
//            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
//            make.centerY.equalTo(avatarImageView)
//        }
//        
//        connectionView.snp.makeConstraints { make in
//            make.height.equalTo(25)
//        }

        let btnStack: UIStackView = {
            let v = UIStackView(arrangedSubviews: [addBtn])
//            let v = UIStackView(arrangedSubviews: [callBtn, addBtn])
//            callBtn.snp.makeConstraints { make in
//                make.size.equalTo(28.w)
//            }
            addBtn.snp.makeConstraints { make in
                make.size.equalTo(28)
            }
            v.axis = .horizontal
            v.distribution = .equalSpacing
            v.spacing = 16
            return v
        }()
        addSubview(btnStack)
        btnStack.snp.makeConstraints { make in
//            make.leading.equalTo(hStack.snp.trailing).offset(8)
//            make.centerY.equalTo(avatarImageView)
            make.centerY.equalTo(titleLbl)
            make.trailing.equalToSuperview().offset(-29)
        }
        
        snp.makeConstraints { make in
            make.height.equalTo(kStatusBarHeight + 44)
        }
//        startListening()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func startListening() {
        // 监听网络状态变化
        reachabilityManager?.startListening()
        reachabilityManager?.listener = { [weak self] status in
            switch status {
            case .notReachable:
                self?.setConnectIndicator(status: .connectFailure, failure: true)
                self?.showConnectionView(true, showIndicator: false)
            default:
                break
            }
        }
    }
    
    private func showConnectionView(_ show: Bool, showIndicator: Bool = false) {
        showIndicator ? connectionIndicator.startAnimating() : connectionIndicator.stopAnimating()
        
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            self?.connectionView.alpha = show ? 1.0 : 0
        }, completion: { [weak self] _ in
            self?.connectionView.isHidden = !show
        })
    }

    func updateConnectionStatus(status: ConnectionStatus) {
        guard reachabilityManager?.isReachable == true else { return }
        // 如果状态发生变更，展示出来
        showConnectionView(status != .syncComplete && status != .connected, showIndicator: true)
        
        if preConnectionStatus != status {
            switch status {
            case .connectFailure, .syncFailure:
                setConnectIndicator(status: status, failure: true)
            case .connecting, .connected, .syncStart, .syncComplete:
                setConnectIndicator(status: status, failure: false)
            case .kickedOffline:
                break
            }
        }
        preConnectionStatus = status
    }
    
    private func setConnectIndicator(status: ConnectionStatus, failure: Bool) {
        if failure {
            connectionLabel.text = status.title
            connectionLabel.textColor = .cFF381F
            connectionIndicator.isHidden = true
            errorImageView.isHidden = false
            connectionView.backgroundColor = .c0089FF.withAlphaComponent(0.15)
        } else {
            connectionLabel.text = status.title
            connectionLabel.textColor = .c0089FF
            errorImageView.isHidden = true
            connectionIndicator.isHidden = false
            connectionView.backgroundColor = .c0089FF.withAlphaComponent(0.15)
        }
    }
}


class tableHeaderSearchView: UIView {
    
    var searchBlock:(()->Void)?
    var btnClickBlock:(()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.top.equalTo(4)
//            make.leading.trailing.equalToSuperview().inset(16.w)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(54)
//            make.bottom.equalTo(-14)
            make.height.equalTo(34)
        }
        
        addSubview(rightImg)
        rightImg.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(11)
            make.width.equalTo(34)
            make.height.equalTo(34)
            make.centerY.equalTo(searchView)
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var searchView: UIView = {
        let v = UIView()
        v.backgroundColor = .init(hexString: "#F5F5F5")
        v.clipsToBounds = true
        v.layer.cornerRadius = 17.w
        v.isUserInteractionEnabled = true
        
        let searchImg = UIImageView(image: UIImage(named: "search_gray"))
        v.addSubview(searchImg)
        searchImg.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14.w)
            make.width.height.equalTo(15.w)
            make.centerY.equalToSuperview()
        }
        
       
        v.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(39.w)
            make.centerY.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(searchDidSelectAction))
        v.isUserInteractionEnabled = true
        v.addGestureRecognizer(tap)
        
        return v
    }()
    
    lazy var titleLbl: UILabel = {
        let titleLbl = UILabel()
        titleLbl.text = "搜索".localized()
        titleLbl.font = UIFont(name: "PingFangSC-Regular", size: 13)
        titleLbl.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        return titleLbl
    }()
    
    lazy var rightImg: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "chat_home_menu")
        let tap = UITapGestureRecognizer(target: self, action: #selector(menuDidSelectAction))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
        return r
    }()
    
    
    @objc func searchDidSelectAction() {
        print("searchDidSelectAction")
        if self.searchBlock != nil {
            print("searchBlock")
            self.searchBlock!()
        }
    }
    
    @objc func menuDidSelectAction() {
        if self.btnClickBlock != nil {
            self.btnClickBlock!()
        }
    }
}
