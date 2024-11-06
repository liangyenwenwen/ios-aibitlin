
import OUICore


public class QRCodeViewController: UIViewController {
    var groupName: String = ""
    var groupID:String = ""
    var groupImage:String = ""
    var groupDetailInfo:GroupInfo?
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private lazy var shadowView: UIView = {
        let v = UIView()
        v.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.08).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 0)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 7
        return v
    }()

    private let backgroundView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 10
        v.backgroundColor = .white
        return v
    }()

    public let avatarView = AvatarView()

    public let nameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.f20
        v.numberOfLines = 2
        v.textColor = UIColor.c0C1C33
        
        return v
    }()

    public let tipLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.f14
        v.textColor = UIColor.c8E9AB0
        
        return v
    }()

    private lazy var codeBackgroundImageView: UIImageView = {
        let v = UIImageView()
        v.layer.borderColor = UIColor.cE8EAEF.cgColor
        v.layer.borderWidth = 4
        
        return v
    }()
    
    
    
    
    lazy var groupCardView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.clipsToBounds = true
        r.layer.cornerRadius = 14
        
        r.addSubview(groupShowTitleView)
        r.addSubview(groupEditTitleView)
        groupEditTitleView.isHidden = true
        r.addSubview(codeView)
        
        codeView.addSubview(codeImgView)
        codeView.addSubview(groupImgView)
        r.addSubview(groupIdTitleView)
        r.addSubview(lineView)
        r.addSubview(cardBottmView)
        groupShowTitleView.snp_makeConstraints { make in
            make.height.equalTo(40)
            make.top.equalTo(38)
            make.centerX.equalTo(codeView)
            make.width.equalTo(260)
        }
        groupEditTitleView.snp_makeConstraints { make in
            make.height.equalTo(40)
            make.top.equalTo(38)
            make.left.right.equalTo(codeView)
        }
        codeView.snp.makeConstraints { make in
            make.width.height.equalTo(260)
            make.top.equalTo(groupShowTitleView.snp_bottom).offset(17)
            make.centerX.equalTo(r)
        }
        codeImgView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview().inset(10)
        }
        groupImgView.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.center.equalToSuperview()
        }
        groupIdTitleView.snp.makeConstraints { make in
            make.top.equalTo(codeView.snp_bottom).offset(24)
            make.height.equalTo(22)
            make.centerX.equalTo(r)
            make.width.equalTo(260)
        }
        lineView.snp.makeConstraints { make in
            make.top.equalTo(groupIdTitleView.snp_bottom).offset(19)
            make.left.right.equalTo(r)
            make.height.equalTo(1)
        }
        cardBottmView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp_bottom)
            make.left.right.equalTo(r)
            make.height.equalTo(50)
        }
        return r
    }()
    ///未编辑状态的q群名
    lazy var groupShowTitleView: UIView = {
        let r = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "edit_icon")
        r.addSubview(groupNicknameLbl)
        r.addSubview(imageView)
        imageView.snp_makeConstraints { make in
            make.left.equalTo(groupNicknameLbl.snp_right).offset(7)
            make.top.equalTo(12)
            make.width.height.equalTo(16)
        }
        groupNicknameLbl.snp_makeConstraints { make in
            make.centerX.equalTo(r.snp_centerX).offset(-12)
            make.top.equalTo(0)
            make.height.equalTo(40)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showGroupNameTFView))
        r.addGestureRecognizer(tap)
        return r
    }()
    
    lazy var groupNicknameLbl: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Medium", size: 15)
        r.textColor = .init(hexString: "#333333")
        r.numberOfLines = 1
        r.text = groupName
        return r
    }()
    
    ///未编辑状态的用户名
    lazy var groupEditTitleView: UIView = {
        let r = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "choose_blue")
        imageView.isUserInteractionEnabled = true
        r.addSubview(groupNicknameTF)
        r.addSubview(imageView)
        imageView.snp_makeConstraints { make in
            make.right.equalTo(r)
            make.top.equalTo(4)
            make.width.height.equalTo(32)
        }
        groupNicknameTF.snp_makeConstraints { make in
            make.left.equalTo(r)
            make.top.equalTo(4)
            make.height.equalTo(32)
            make.right.equalTo(imageView.snp_left).offset(-7)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(showNicknameLblView))
        imageView.addGestureRecognizer(tap)
        
        return r
    }()
    
    lazy var groupNicknameTF: UITextField = {
        let r = UITextField()
        r.backgroundColor = .init(hexString: "#F5F5F5")
        r.clipsToBounds = true
        r.layer.cornerRadius = 8
        r.text = groupName
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 32))
        r.leftView = paddingView
        r.leftViewMode = .always
        r.rightView = paddingView
        r.rightViewMode = .always
        return r
    }()
    
    lazy var codeView: UIView = {
        let r = UIView()
        r.clipsToBounds = true
        r.layer.borderWidth = 1
        r.layer.cornerRadius = 8
        let color:UIColor = .init(hexString:"#EAEAEA")!
        r.layer.borderColor = color.cgColor
        return r
    }()
    
    lazy var codeImgView: UIImageView = {
        let r = UIImageView()
        return r
    }()
    
    lazy var groupImgView: AvatarView = {
        let r = AvatarView()
        r.clipsToBounds = true
        r.layer.borderWidth = 3
        r.layer.cornerRadius = 28
        r.layer.borderColor = UIColor.white.cgColor
        r.contentMode = .scaleAspectFill
        return r
    }()
    
    ///用户id展示
    lazy var groupIdTitleView: UIView = {
        let r = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "copy_icon")
        imageView.isUserInteractionEnabled = true
        r.addSubview(groupIDLbl)
        r.addSubview(imageView)
        imageView.snp_makeConstraints { make in
            make.left.equalTo(groupIDLbl.snp_right).offset(7)
            make.top.equalTo(3)
            make.width.height.equalTo(16)
        }
        groupIDLbl.snp_makeConstraints { make in
            make.centerX.equalTo(r.snp_centerX).offset(-12)
            make.top.equalTo(0)
            make.height.equalTo(22)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyGroupID))
        imageView.addGestureRecognizer(tap)
        return r
    }()
    

    
    lazy var groupIDLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .init(hexString: "#666666")
        lbl.font = UIFont(name: "PingFangSC-Regular", size: 13)
        lbl.text = "ID: ".localized() + groupID ?? ""
        return lbl
    }()
    
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#eaeaea")
        return r
    }()
    
    lazy var cardBottmView: UIView = {
        let r = UIView()
        
        let lineView = UIView()
        lineView.backgroundColor = .init(hexString: "#eaeaea")
        r.addSubview(shareView)
        r.addSubview(lineView)
        r.addSubview(saveView)
        shareView.snp_makeConstraints { make in
            make.left.top.bottom.equalTo(r)
            make.right.equalTo(lineView.snp_left)
        }
        lineView.snp_makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(15)
            make.center.equalTo(r)
        }
        saveView.snp_makeConstraints { make in
            make.right.top.bottom.equalTo(r)
            make.left.equalTo(lineView.snp_right)
        }
        return r
    }()
    
    lazy var shareView: UIView = {
        let r = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "share_icon")
        let lbl = UILabel()
        lbl.font = UIFont(name: "PingFangSC-Regular", size: 14)
        lbl.textColor = .init(hexString: "#333333")
        lbl.text = "分享给好友".innerLocalized();
        r.addSubview(imageView)
        r.addSubview(lbl)
        imageView.snp_makeConstraints { make in
            make.right.equalTo(lbl.snp_left).offset(-5)
            make.centerY.equalTo(r)
            make.width.height.equalTo(16)
        }
        lbl.snp_makeConstraints { make in
            make.centerY.equalTo(r)
            make.centerX.equalTo(r.snp_centerX).offset(11)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(shareCode))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
        
        return r
    }()
    
    
    lazy var saveView: UIView = {
        
        let r = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "save_icon")
        let lbl = UILabel()
        lbl.font = UIFont(name: "PingFangSC-Regular", size: 14)
        lbl.textColor = .init(hexString: "#333333")
        lbl.text = "保存到手机".innerLocalized();
        r.addSubview(imageView)
        r.addSubview(lbl)
        imageView.snp_makeConstraints { make in
            make.right.equalTo(lbl.snp_left).offset(-5)
            make.centerY.equalTo(r)
            make.width.height.equalTo(16)
        }
        lbl.snp_makeConstraints { make in
            make.centerY.equalTo(r)
            make.centerX.equalTo(r.snp_centerX).offset(11)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(saveQRCode))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
        
        return r
    }()
    
    

    private let codeContentImageView: UIImageView = .init()

    public init(idString: String) {
        super.init(nibName: nil, bundle: nil)
        DispatchQueue.global().async {
            let image = CodeImageGenerator.createQRCodeImage(content: idString, size: CGSize(width: 140, height: 140), foregroundColor: UIColor.black, backgroundColor: UIColor.clear)
            DispatchQueue.main.async {
                self.codeImgView.image = image
            }
        }
    }
//    public init(idString: String) {
//        super.init(nibName: nil, bundle: nil)
//        DispatchQueue.global().async {
//            let image = CodeImageGenerator.createQRCodeImage(content: idString, size: CGSize(width: 140, height: 140), foregroundColor: UIColor.black, backgroundColor: UIColor.clear)
//            DispatchQueue.main.async {
//                self.codeImgView.image = image
//            }
//        }
//    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(hexString: "f5f5f5")

        navigationItem.title = "qrcode".innerLocalized()
        initView()
        bindData()
        refreshUI()
        
//        let button = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(yourActionMethod))
//        let button = UIBarButtonItem(image: .init(named: "arrowLeft"), style: .plain, target: self, action: #selector(yourActionMethod))
//        navigationItem.leftBarButtonItem = button
    }
    
    @objc func yourActionMethod() {
        self.navigationController?.popViewController(animated: true)
    }

    private func initView() {
//        shadowView.addSubview(backgroundView)
//        backgroundView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//
//        backgroundView.addSubview(avatarView)
//        avatarView.snp.makeConstraints { make in
//            make.top.left.equalToSuperview().inset(30)
//        }
//
//        backgroundView.addSubview(nameLabel)
//        nameLabel.snp.makeConstraints { make in
//            make.left.equalTo(avatarView.snp.right).offset(13)
//            make.right.equalToSuperview().offset(-20)
//            make.centerY.equalTo(avatarView)
//        }
//
//        backgroundView.addSubview(tipLabel)
//        tipLabel.snp.makeConstraints { make in
//            make.top.equalTo(avatarView.snp.bottom).offset(56)
//            make.centerX.equalToSuperview()
//        }
//
//        backgroundView.addSubview(codeBackgroundImageView)
//        codeBackgroundImageView.snp.makeConstraints { make in
//            make.top.equalTo(tipLabel.snp.bottom).offset(30)
//            make.centerX.equalToSuperview()
//            make.size.equalTo(180)
//            make.bottom.equalToSuperview().offset(-80)
//        }
//
//        codeBackgroundImageView.addSubview(codeContentImageView)
//        codeContentImageView.snp.makeConstraints { make in
//            make.center.equalToSuperview()
//        }

        view.addSubview(groupCardView)
//        shadowView.addSubview(groupCardView)
//        shadowView.snp.makeConstraints { make in
//            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(58)
//            make.left.right.equalToSuperview().inset(StandardUI.margin_22)
//        }
        groupCardView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(58)
            make.height.equalTo(471)
        }
    }
    @objc func showNicknameLblView() {
        groupShowTitleView.isHidden = false
        groupEditTitleView.isHidden = true
        view.endEditing(true)
        groupName = groupNicknameTF.text!
        groupNicknameLbl.text = groupName
    }
    
    @objc func showGroupNameTFView() {
        
        groupShowTitleView.isHidden = true
        groupEditTitleView.isHidden = false

        groupNicknameTF.text = groupName
        
    }
    
    @objc func copyGroupID() {
        UIPasteboard.general.string = groupID
        if let handler = OIMApi.showTipHandle {
            handler("复制成功".innerLocalized(), { res in
            })
        }
    }
    
    
    @objc func saveQRCode() {
        guard let image = getShareCardImg(view: groupCardView) else {return}
            // 保存图片到相册
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
      
    }
    @objc func image(image: UIImage, didFinishSavingWithError: NSError?,contextInfo: AnyObject)

    {

        if didFinishSavingWithError != nil {
            
            print("error!")
            
            return
        }

        print("图片保存成功".innerLocalized())
        if let handler = OIMApi.showTipHandle {
            handler("图片保存成功".innerLocalized(), { res in
            })
        }
    }
    
    @objc func shareCode() {
        guard let image = getShareCardImg(view: groupCardView) else {return}
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(activityViewController, animated: true)
    }
    func refreshUI() {
        groupImgView.setGroupInfoImg(item: groupDetailInfo!)
        groupNicknameLbl.text = groupName
        groupNicknameTF.text = groupName
        groupIDLbl.text = groupID
        
       
        
        
    }
    func  getShareCardImg(view:UIView ) -> UIImage? {
        
        // 开始图形上下文
        UIGraphicsBeginImageContextWithOptions(view.bounds.size,  false, 0.0)
        defer { UIGraphicsEndImageContext() } // 确保上下文能被释放
        
        // 将view渲染到图形上下文中
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
//                view.isHidden = true
        } else {
//                view.isHidden = true
        }
        
        // 从图形上下文获取图片
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        return image
    }
    private func bindData() {}
}
