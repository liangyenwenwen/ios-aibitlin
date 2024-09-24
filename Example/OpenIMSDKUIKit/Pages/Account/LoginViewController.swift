
import UIKit
import RxSwift
import RxCocoa
import RxGesture
import MMBAlertsPickers
import SnapKit
import ProgressHUD
import OUICore

enum LoginType: Int {
    case phone = 0
    case email = 1
    
    var name: String {
        switch (self) {
              case .phone:
            return "phoneNumber".localized();
              case .email:
            return "email".localized();
            }
    }
    
    var hintText: String {
       switch (self) {
         case .phone:
           return "plsEnterPhoneNumber".localized();
         case .email:
           return "plsEnterEmail".localized();
       }
     }
}

let loginTypeKey = "com.oimuikit.login.type"

class LoginViewController: UIViewController {
    
    private let _disposeBag = DisposeBag()
    
    private var _areaCode = "+86"
    
    public var loginType: LoginType = LoginType(rawValue: UserDefaults.standard.integer(forKey: loginTypeKey)) ?? .phone
    
    private var  operateType = LoginType.phone;
    
    private let logoImageView: UIImageView = {
        let v = UIImageView(image: UIImage(named: "logo_image"))
        v.isUserInteractionEnabled = true
        
        return v
    }()
    
    
    private let titleLabel: UILabel = {
        let v = UILabel()
        v.text = "welcome".localized()
        v.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        v.textColor = DemoUI.color_0089FF
        
        return v
    }()
    
    private lazy var phoneLabel: UILabel = {
        let v = UILabel()
        var placeholder = "phoneNumber".localized()
        #if ENABLE_ORGANIZATION
        placeholder = "account".localized()
        #endif
        v.text = placeholder
        v.font = .f12
        v.textColor = .c8E9AB0
        
        return v
    }()
    
    lazy var registerButton: UIButton = {
        let t = UIButton(type: .system)
        t.setTitle("registerNow".localized(), for: .normal)
        t.titleLabel?.font = .f12

        t.rx.tap.subscribe(onNext: { [unowned self] _ in
            showRegisterBottomSheet()
        }).disposed(by: _disposeBag)
        
        return t
    }()
    
    lazy var forgotButton: UIButton = {
        let t = UIButton(type: .system)
        t.setTitle("forgetPassword".localized(), for: .normal)
        t.setTitleColor(DemoUI.color_8E9AB0, for: .normal)
        t.titleLabel?.font = .f12

        t.rx.tap.subscribe(onNext: { [unowned self] _ in
            showForgotPasswordBottomSheet()
        }).disposed(by: _disposeBag)
        
        return t
    }()
    
    lazy var codeLoginButton: UIButton = {
        let t = UIButton(type: .custom)
        t.setTitle("verificationCodeLogin".localized(), for: .normal)
        t.setTitle("passwordLogin".localized(), for: .selected)
        t.setTitleColor(DemoUI.color_0089FF, for: .selected)
        t.setTitleColor(DemoUI.color_0089FF, for: .normal)
        t.titleLabel?.font = .f12
        
        t.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let sself = self else { return }
            t.isSelected = !t.isSelected
            sself.toCodeLogin()
        }).disposed(by: _disposeBag)
        return t
    }()
    
    lazy var checkBoxButton: UIButton = {
        let t = UIButton(type: .custom)
        t.setImage(UIImage(named: "common_checkbox_unselected"), for: .normal)
        t.setImage(UIImage(named: "common_checkbox_selected"), for: .selected)
        t.isSelected = true
        
        t.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let sself = self else { return }
            sself.agreeProtocal()
        }).disposed(by: _disposeBag)
        
        return t
    }()
    
    var phone: String? {
        return phoneTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var password: String? {
        return !codeLoginButton.isSelected ? passwordTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) : nil
    }
    
    var areaCode: String {
        return _areaCode
    }
    
    var verificationCode: String? {
        return codeLoginButton.isSelected ? passwordTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) : nil
    }
    
    let countDownButton: CountDownTimerButton = {
        let t = CountDownTimerButton()
        
        return t
    }()
    
    lazy var areaCodeButton: UIButton = {
        let t = UIButton(type: .custom)
        t.setTitle("\(_areaCode)", for: .normal)
        t.setTitleColor(DemoUI.color_0C1C33, for: .normal)
        t.titleLabel?.font = .systemFont(ofSize: 17)
        
        //手机号 区域 弹窗
        t.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let sself = self else { return }
            let alert = UIAlertController(style: .actionSheet, title: "Phone Codes")
            alert.addLocalePicker(type: .phoneCode) {[weak self] info in
                // action with selected object
                guard let phoneCode = info?.phoneCode else {return}
                self?._areaCode = phoneCode
                t.setTitle("\(phoneCode)", for: .normal)
            }
            
            alert.addAction(title: "cancel".localized(), style: .cancel)
            sself.present(alert, animated: true)
        }).disposed(by: _disposeBag)
        return t
    }()
    
    private lazy var phoneTextField: UITextField = {
        let v = UITextField()
        v.keyboardType = .numberPad
        var placeholder = "plsEnterPhoneNumber".localized()
        #if ENABLE_ORGANIZATION
        placeholder = "请输入账号".localized()
        #endif
        v.placeholder = placeholder
        v.clearButtonMode = .whileEditing
        v.text = AccountViewModel.perLoginAccount
        v.textColor = DemoUI.color_0C1C33
        
        let rightView = InputFiledRightView()
        rightView.eyesButton.isHidden = true
        v.rightView = rightView
        v.rightViewMode = .always
        
        rightView.onButtonClicked = { [weak self] type in
            if type == .clear {
                v.text = nil
                v.sendActions(for: .allEditingEvents)
            }
        }
        
        return v
    }()
    
    private let passwordLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 14)
        v.textColor = DemoUI.color_333333
        v.text = "password".localized()
        v.textColor = DemoUI.color_8E9AB0
        v.font = DemoUI.smallFont
        
        return v
    }()
    
    private lazy var pswRightView: InputFiledRightView = {
        let v = InputFiledRightView()

        v.onButtonClicked = { [weak self] type in
            guard let self else { return }
            
            if type == .clear {
                passwordTextField.text = nil
                passwordTextField.sendActions(for: .allEditingEvents)
            } else {
                passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
            }
        }
        
        return v
    }()
    
    private lazy var passwordTextField: UITextField = {
        let v = UITextField()
        v.placeholder = "plsEnterPassword".localized()
        v.isSecureTextEntry = true
        v.layer.cornerRadius = DemoUI.cornerRadius
        v.layer.borderColor = DemoUI.color_E8EAEF.cgColor
        v.layer.borderWidth = 1
        v.borderStyle = .none
        v.textColor = DemoUI.color_0C1C33
        v.clearButtonMode = .whileEditing
        v.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 1))
        v.leftViewMode = .always
        v.rightView = pswRightView
        v.rightViewMode = .always
        
        return v
    }()
    
    lazy var loginBtn: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Log in".localized(), for: .normal)
        v.setTitleColor(.white, for: .normal)
        v.titleLabel?.font = .f20
        v.layer.cornerRadius = DemoUI.cornerRadius
        v.layer.masksToBounds = true
        v.setBackgroundColor(.c0089FF, for: .normal)
        v.setBackgroundColor(.c0089FF.withAlphaComponent(0.5), for: .disabled)

        v.isEnabled = false
        
        return v
    }()
    
    lazy var loginTypeBtn: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("email".localized() + "login".localized(), for: .normal)
        v.backgroundColor = .systemGray6
        v.titleLabel?.font = .f20
        v.layer.cornerRadius = DemoUI.cornerRadius
        v.addTarget(self, action: #selector(loginTypeBtnAction), for: .touchUpInside)
        
        return v
    }()
    
    @objc
    private func loginTypeBtnAction() {
        toggleLoginType()
    }
    
    lazy var versionLabel: UILabel = {
        let v = UILabel()
        v.text = AboutUsViewController.version
        
        return v
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let bgImageView = UIImageView(image: UIImage(named: "login_bg"))
        bgImageView.frame = view.bounds
        view.addSubview(bgImageView)
        
        bindData()
        
        countDownButton.clickedBlock = { [weak self] sender in
            guard let sself = self,
                  let phone = sself.phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            
            AccountViewModel.requestCode(phone: phone, areaCode: sself.areaCode, useFor: .login) { (errCode, errMsg) in
                if errMsg != nil {
                    ProgressHUD.error(errCode == -1 ? errMsg : String(errCode).localized())
                } else {
                    ProgressHUD.success("发送".localized() + "成功".localized())
                }
            }
        }
        
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(88.h)
            make.size.equalTo(64.w)
        }
        
        logoImageView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                let vc = ConfigViewController()
                let nav = UINavigationController(rootViewController: vc)
                self?.present(nav, animated: true)
            }).disposed(by: _disposeBag)
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(8.h)
            make.centerX.equalToSuperview()
        }
        
        // 登录
        let container: UIView = {
            let v = UIView()
            return v
        }()
        
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(50.h)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        container.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        let line = UIView()
        line.backgroundColor = DemoUI.color_E8EAEF
        
        let accountStack = UIStackView(arrangedSubviews: [areaCodeButton, line, phoneTextField])
        accountStack.spacing = 8
        accountStack.alignment = .center
        accountStack.layer.cornerRadius = DemoUI.cornerRadius
        accountStack.layer.borderColor = DemoUI.color_E8EAEF.cgColor
        accountStack.layer.borderWidth = 1
        
        phoneTextField.setContentHuggingPriority(UILayoutPriority(248), for: .horizontal)
        
        areaCodeButton.snp.makeConstraints { make in
            make.width.equalTo(60)
        }
        
        container.addSubview(accountStack)
        accountStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(phoneLabel.snp.bottom).offset(4)
        }
        
        line.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.top.bottom.equalToSuperview().inset(4)
        }
        
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(42.h)
        }
        
        container.addSubview(passwordLabel)
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(accountStack.snp.bottom).offset(16.h)
            make.left.equalToSuperview()
        }
        
        container.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(6)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(42.h)
        }
        
#if ENABLE_ORGANIZATION
#else
        view.addSubview(forgotButton)
        forgotButton.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom).offset(6.h)
            make.leading.equalTo(container)
        }
        
        view.addSubview(codeLoginButton)
        codeLoginButton.snp.makeConstraints { make in
            make.top.equalTo(forgotButton)
            make.trailing.equalTo(container)
        }
#endif
        
        view.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { make in
            make.height.equalTo(42.h)
            make.top.equalTo(forgotButton.snp.bottom).offset(46.h)
            make.leading.trailing.equalTo(container)
        }
        
        let loginLine = UIView()
        loginLine.backgroundColor = .systemGray5
        
        view.addSubview(loginLine)
        loginLine.snp.makeConstraints { make in
            make.top.equalTo(loginBtn.snp.bottom).offset(23.h)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        view.addSubview(loginTypeBtn)
        loginTypeBtn.snp.makeConstraints { make in
            make.height.equalTo(42.h)
            make.top.equalTo(loginLine.snp.bottom).offset(23.h)
            make.leading.trailing.equalTo(container)
        }
        
        let protocalLabel = UILabel()
        protocalLabel.isUserInteractionEnabled = true
        protocalLabel.font = .systemFont(ofSize: 13)
        let text = NSMutableAttributedString.init(string: "我已阅读并同意:".localized())
        text.append(NSAttributedString(string: "《服务协议》《隐私权政策》".localized(), attributes: [NSAttributedString.Key.foregroundColor: DemoUI.color_1D6BED]))
        protocalLabel.attributedText = text
        
        protocalLabel.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let sself = self else { return }
                sself.toPrivacyRule()
            }).disposed(by: _disposeBag)
        
        // 协议
        let horSV = UIStackView.init(arrangedSubviews: [checkBoxButton, protocalLabel])
        horSV.alignment = .center
        horSV.spacing = 8
//        view.addSubview(horSV)
        
//        horSV.snp.makeConstraints { make in
//            make.leading.trailing.equalTo(loginBtn)
//            make.top.equalTo(loginTypeBtn.snp.bottom).offset(16)
//        }
        #if ENABLE_ORGANIZATION
        #else
        // 注册/找回密码
        let label = UILabel()
        label.textColor = DemoUI.color_8E9AB0
        
        label.font = .f12
        label.text = "noAccountYet".localized()
        let horSV2 = UIStackView.init(arrangedSubviews: [UIView(), label, registerButton, UIView()])
        horSV2.alignment = .center
        view.addSubview(horSV2)
        
        horSV2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(loginTypeBtn.snp.bottom).offset(100.h)
        }
        #endif
        
        view.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(horSV2.snp.bottom).offset(32.h)
        }
        
        let tap = UITapGestureRecognizer()
        view.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            view.endEditing(true)
        }).disposed(by: _disposeBag)
        loginType == .phone ? setPhoneLogin() : setEmailLogin()

    }
    
    private func bindData() {
        Observable.combineLatest(phoneTextField.rx.text.orEmpty, passwordTextField.rx.text.orEmpty) {
            $0.count > 0 && $1.count > 0
        }
        .bind(to: loginBtn.rx.isEnabled)
        .disposed(by: _disposeBag)
    }
    
    deinit {
#if DEBUG
        print("dealloc \(type(of: self))")
#endif
    }
    
    func toRegister() {
        let vc = InputAccountViewController(operateType: operateType)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func toCodeLogin() {
        passwordTextField.text = nil
        passwordTextField.sendActions(for: .allEditingEvents)

        if codeLoginButton.isSelected {
            passwordTextField.rightView = countDownButton
        } else {
            passwordTextField.rightView = pswRightView
        }
    }
    
    func toForgotPassword() {
        let vc = InputAccountViewController(usedFor: .forgotPassword, operateType: operateType)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func agreeProtocal() {
        checkBoxButton.isSelected = !checkBoxButton.isSelected
    }
    
    func toPrivacyRule() {
        UIApplication.shared.openURL(NSURL.init(string:"https://www.openim.io/")! as URL);
    }
    
    func toggleLoginType() {
        phoneTextField.text = nil
        
        if loginType == .phone {
            setEmailLogin()
        } else {
            setPhoneLogin()
        }
    }
    
    func setPhoneLogin() {
        loginType = .phone
        areaCodeButton.isHidden = false
        phoneTextField.placeholder = "plsEnterPhoneNumber".localized()
        phoneTextField.keyboardType = .phonePad
        phoneLabel.text = "phoneNumber".localized()
        loginTypeBtn.setTitle("email".localized() + "login".localized(), for: .normal)
    }
    
    func setEmailLogin() {
        loginType = .email
        areaCodeButton.isHidden = true
        phoneTextField.placeholder = "plsEnterEmail".localized()
        phoneTextField.keyboardType = .default
        phoneLabel.text = "email".localized()
        loginTypeBtn.setTitle("phoneNumber".localized() + "login".localized(), for: .normal)
    }
    
    func showRegisterBottomSheet() {
        presentActionSheet(useRoot: false, action1Title: "email".localized() + "registerNow".localized(), action1Handler: { [weak self] in
            self?.operateType = .email
            self?.toRegister()
        }, action2Title: "phoneNumber".localized() + "registerNow".localized()) { [weak self] in
            self?.operateType = .phone
            self?.toRegister()
        }
    }
    
    func showForgotPasswordBottomSheet() {
        presentActionSheet(useRoot: false, action1Title: "through".localizedFormat("email".localized()), action1Handler: { [weak self] in
            self?.operateType = .email
            self?.toForgotPassword()
        }, action2Title: "through".localizedFormat("phoneNumber".localized())) { [weak self] in
            self?.operateType = .phone
            self?.toForgotPassword()
        }
    }
}

class InputFiledRightView: UIView {
    
    public enum ButtonType {
        case clear
        case eye
    }
    
    public var onButtonClicked: ((ButtonType) -> Void)?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var eyesButton: UIButton = {
        let v = UIButton(type: .custom)

        v.setImage(UIImage(named: "ic_eyes_close"), for: .normal)
        v.setImage(UIImage(named: "ic_eyes_open"), for: .selected)
        v.isSelected = false
            
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            v.isSelected = !v.isSelected
            guard let self else { return }
            
            onButtonClicked?(.eye)
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    lazy var clearButton: UIButton = {
        let v = UIButton(type: .custom)
        v.setImage(UIImage(named: "ic_clear"), for: .normal)
        
        v.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            
            onButtonClicked?(.clear)
        }).disposed(by: disposeBag)
        
        return v
    }()
    
    private let disposeBag = DisposeBag()
    
    private func setupSubviews() {
        let hSV = UIStackView(arrangedSubviews: [clearButton, eyesButton])
        hSV.spacing = 8
        
        addSubview(hSV)
        hSV.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
}
