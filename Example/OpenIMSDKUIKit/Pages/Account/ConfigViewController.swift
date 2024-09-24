import UIKit
import RxSwift
import RxCocoa
import Localize_Swift

let severAddressKey = "com.oimuikit.adr"
//let serverAddressKey = "https://im-api.bitswith.com"  //服务器地址
let adminSeverAddrKey = "io.openim.admin.adr"
let bussinessSeverAddrKey = "io.openim.bussiness.api.adr"
//let bussinessSeverAddrKey = "im-chat-api.bitswith.com"   //业务服务器地址
let sdkAPIAddrKey = "io.openim.sdk.api.adr"
//let sdkAPIAddrKey = "im-api.bitswith.com"   //IM API 地址
let sdkWSAddrKey = "io.openim.sdk.ws.adr"
//let sdkWSAddrKey = "im-msg-gateway.bitswith.com"   //IM WS地址
let sdkObjectStorageKey = "io.openim.sdk.os"
let useDomainKey = "io.openim.use.domain"
let useTLSKey = "io.openim.use.TLS"

class ConfigViewController: UIViewController {
    
//    private var severAddress = UserDefaults.standard.string(forKey: severAddressKey) ?? defaultHost
    ///测试修改
    private var bussinessSeverAddr = UserDefaults.standard.string(forKey: bussinessSeverAddrKey) ??
    "https://\(defaultAppAddress)\(bussinessRoute)"
    private var sdkAPIAddr = UserDefaults.standard.string(forKey: sdkAPIAddrKey) ??
    "https://\(defaultIMAddress)\(sdkAPIRoute)"
    private var sdkWSAddr = UserDefaults.standard.string(forKey: sdkWSAddrKey) ??
    "wss://\(defaultIMAddress)\(sdkWSRoute)"
    
    private let disposeBag = DisposeBag()
    
//    private lazy var serverAddressTextField: UITextField = {
//        let v = UITextField()
//        v.text = severAddress
//        v.borderStyle = .roundedRect
//        
//        return v
//    }()
    
    private lazy var loginServerAddressTextField: UITextField = {
        let v = UITextField()
        v.borderStyle = .roundedRect
        
        return v
    }()
    
    private lazy var imApiServerAddressTextField: UITextField = {
        let v = UITextField()
        v.borderStyle = .roundedRect
        
        return v
    }()
    
    private lazy var imWSServerAddressTextField: UITextField = {
        let v = UITextField()
        v.borderStyle = .roundedRect
        
        return v
    }()
    
    private lazy var useDomainSegmented: UISegmentedControl = {
        let v =  UISegmentedControl(items: ["switchToIP".localized(), "switchToDomain".localized()])
        v.selectedSegmentIndex = UserDefaults.standard.bool(forKey: useDomainKey) ? 1 : 0
        v.addTarget(self, action: #selector(handleDomainChanged(_:)), for: .valueChanged)
        
        return v
    }()
    
    @objc private func handleDomainChanged(_ sender: UISegmentedControl) {
        useTLSSwitch.selectedSegmentIndex = useDomainSegmented.selectedSegmentIndex
        let httpScheme = useDomainSegmented.selectedSegmentIndex == 0 ? "http://" : "https://"
        let wsScheme = useDomainSegmented.selectedSegmentIndex == 0 ? "ws://" : "wss://"
        let texts = useDomainSegmented.selectedSegmentIndex == 0 ? [bussinessPort, sdkAPIPort, sdkWSPort] : [bussinessRoute, sdkAPIRoute, sdkWSRoute]
        let appServerAddr = useDomainSegmented.selectedSegmentIndex == 0 ? "127.0.0.1" : defaultAppAddress
        let IMServerAddr = useDomainSegmented.selectedSegmentIndex == 0 ? "127.0.0.1" : defaultIMAddress
        
//        serverAddressTextField.text = nil
//        serverAddressTextField.placeholder = "\("suchAs".localized()): \(serverAddr)"
        loginServerAddressTextField.text = nil
        loginServerAddressTextField.placeholder = "\("suchAs".localized()): \(httpScheme)\(appServerAddr)\(texts[0])"
        imApiServerAddressTextField.text = nil
        imApiServerAddressTextField.placeholder = "\("suchAs".localized()): \(httpScheme)\(IMServerAddr)\(texts[1])"
        imWSServerAddressTextField.text = nil
        imWSServerAddressTextField.placeholder = "\("suchAs".localized()): \(wsScheme)\(IMServerAddr)\(texts[2])"
    }
    
    private let useTLSSwitch: UISegmentedControl = {
        let v = UISegmentedControl(items: ["关闭TLS", "开启TLS"])
        v.selectedSegmentIndex = 1
        
        return v
    }()
    
    private let scrollView = UIScrollView()
    
    @objc func saveAddress() {
        self.view.endEditing(true)
        
        let ud = UserDefaults.standard
//        ud.set(serverAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), forKey: severAddressKey)
        ud.set(loginServerAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), forKey: bussinessSeverAddrKey)
        ud.set(imApiServerAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), forKey: sdkAPIAddrKey)
        ud.set(imWSServerAddressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), forKey: sdkWSAddrKey)
        ud.set(useTLSSwitch.selectedSegmentIndex == 1, forKey: useTLSKey)
        ud.set(useDomainSegmented.selectedSegmentIndex == 1, forKey: useDomainKey)
        ud.synchronize()
        AccountViewModel.saveUser(uid: AccountViewModel.userID , imToken: nil, chatToken: nil)
        let alert = UIAlertController.init(title: nil, message: "serverSettingTips".localized(), preferredStyle: .alert)
        alert.addAction(.init(title: "确定".localized(), style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    private var enableTSL: Bool {
        return UserDefaults.standard.object(forKey: useTLSKey) == nil ? useTLSSwitch.selectedSegmentIndex == 1 : UserDefaults.standard.bool(forKey: useTLSKey)
    }
    
    private var enableRoute: Bool {
        return UserDefaults.standard.object(forKey: useDomainKey) == nil ? useDomainSegmented.selectedSegmentIndex == 1 : UserDefaults.standard.bool(forKey: useDomainKey)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindUI()
        setupKeyboardNotifications()
//        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configureUI() {
        navigationItem.rightBarButtonItem = .init(title: "save".localized(), style: .done, target: self, action: #selector(saveAddress))
        view.backgroundColor = .viewBackgroundColor
        
//        // Add a "使用IP" label and switch
//        let ipAddressLabel = UILabel()
//        let ipAddressStackView = UIStackView(arrangedSubviews: [ipAddressLabel, useRouteSegmented])
//        ipAddressStackView.axis = .horizontal
//        ipAddressStackView.spacing = 10
//        
//        // Add a "使用TLS" label and switch
//        let tlsLabel = UILabel()
//        tlsLabel.text = "使用TLS".localized()
//        let tlsStackView = UIStackView(arrangedSubviews: [tlsLabel, useTLSSwitch])
//        tlsStackView.axis = .horizontal
//        tlsStackView.spacing = 10
        
//        let hStack = UIStackView(arrangedSubviews: [UIView(), useTLSSwitch, useRouteSegmented, UIView()])
//        hStack.spacing = 32
//        hStack.alignment = .center
        
        let serverLabel = UILabel()
        serverLabel.text = "serverAddress".localized()
        
//        let serverStackView = UIStackView(arrangedSubviews: [serverLabel, serverAddressTextField])
//        serverStackView.axis = .vertical
//        serverStackView.spacing = 10
        
        let loginServerLabel = UILabel()
        loginServerLabel.text = "appAddress".localized()
        
        let loginServerStackView = UIStackView(arrangedSubviews: [loginServerLabel, loginServerAddressTextField])
        loginServerStackView.axis = .vertical
        loginServerStackView.spacing = 10
        
        let imApiServerLabel = UILabel()
        imApiServerLabel.text = "sdkApiAddress".localized()
        
        let imApiServerStackView = UIStackView(arrangedSubviews: [imApiServerLabel, imApiServerAddressTextField])
        imApiServerStackView.axis = .vertical
        imApiServerStackView.spacing = 10
        
        let imWSServerLabel = UILabel()
        imWSServerLabel.text = "sdkWsAddress".localized()
        
        let imWSStackView = UIStackView(arrangedSubviews: [imWSServerLabel, imWSServerAddressTextField])
        imWSStackView.axis = .vertical
        imWSStackView.spacing = 10
        
        let vStack = UIStackView(arrangedSubviews: [useDomainSegmented, /*serverStackView,*/ loginServerStackView, imApiServerStackView, imWSStackView])
        vStack.axis = .vertical
        vStack.spacing = 24
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        
        let httpScheme = useDomainSegmented.selectedSegmentIndex == 0 ? "http://" : "https://"
        let wsScheme = useDomainSegmented.selectedSegmentIndex == 0 ? "ws://" : "wss://"
        let appServerAddr = useDomainSegmented.selectedSegmentIndex == 0 ? "127.0.0.1" : defaultAppAddress
        let IMServerAddr = useDomainSegmented.selectedSegmentIndex == 0 ? "127.0.0.1" : defaultIMAddress
        
        loginServerAddressTextField.placeholder = "\("suchAs".localized()): \(httpScheme)\(appServerAddr)\(bussinessRoute)"
        imApiServerAddressTextField.placeholder = "\("suchAs".localized()): \(httpScheme)\(IMServerAddr)\(sdkAPIRoute)"
        imWSServerAddressTextField.placeholder = "\("suchAs".localized()): \(wsScheme)\(IMServerAddr)\(sdkWSRoute)"
        
        loginServerAddressTextField.text = bussinessSeverAddr
        imApiServerAddressTextField.text = sdkAPIAddr
        imWSServerAddressTextField.text = sdkWSAddr
    }
    
    private func bindUI() {
//        useTLSSwitch.rx.selectedSegmentIndex.asObservable()
//            .map { index in
//                switch index {
//                case 0:
//                    return ["http://", "ws://"]
//                case 1:
//                    return ["https://", "wss://"]
//                default:
//                    return ["http://", "ws://"]
//                }
//            }
//            .subscribe(onNext: { [weak self] (texts: [String]) in
//                guard let self else { return }
//                
//                var temp: String = loginServerAddressTextField.text!
//                temp = loginServerAddressTextField.text!
//                loginServerAddressTextField.text = texts[0] + temp.components(separatedBy: "//").last!
//                
//                temp = imApiServerAddressTextField.text!
//                imApiServerAddressTextField.text = texts[0] + temp.components(separatedBy: "//").last!
//                
//                temp = imWSServerAddressTextField.text!
//                imWSServerAddressTextField.text = texts[1] + temp.components(separatedBy: "//").last!
//            })
//            .disposed(by: disposeBag)
        
//        let textField1Observable = loginServerAddressTextField.rx.text.asObservable()
//        let textField2Observable = imApiServerAddressTextField.rx.text.asObservable()
//        let textField3Observable = imWSServerAddressTextField.rx.text.asObservable()
//
//            let isButtonEnabledObservable = Observable.combineLatest(textField1Observable, textField2Observable, textField3Observable)
//            { (text1, text2, text3) -> Bool in
//                return text1?.isEmpty == false && text2?.isEmpty == false && text3?.isEmpty == false
//            }
//            
//        isButtonEnabledObservable.bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled).disposed(by: disposeBag)

//        useDomainSegmented.rx.selectedSegmentIndex.asObservable()
//            .map { index in
//                switch index {
//                case 0:
//                    return [bussinessPort, sdkAPIPort, sdkWSPort]
//                case 1:
//                    return [bussinessRoute, sdkAPIRoute, sdkWSRoute]
//                default:
//                    return [bussinessPort, sdkAPIPort, sdkWSPort]
//                }
//            }
//            .subscribe(onNext: { [weak self] texts in
//                guard let self else { return }
//                
//                let httpScheme = useDomainSegmented.selectedSegmentIndex == 0 ? "http://" : "https://"
//                let wsScheme = useDomainSegmented.selectedSegmentIndex == 0 ? "ws://" : "wss://"
//                let serverAddr = useDomainSegmented.selectedSegmentIndex == 0 ? defaultIP : defaultDomain
//                
//                serverAddressTextField.text = nil
//                serverAddressTextField.placeholder = "\("suchAs".localized()): \(httpScheme)\(serverAddr)"
//                loginServerAddressTextField.text = nil
//                loginServerAddressTextField.placeholder = "\("suchAs".localized()): \(httpScheme)\(serverAddr)\(texts[0])"
//                imApiServerAddressTextField.text = nil
//                imApiServerAddressTextField.placeholder = "\("suchAs".localized()): \(httpScheme)\(serverAddr)\(texts[1])"
//                imWSServerAddressTextField.text = nil
//                imWSServerAddressTextField.placeholder = "\("suchAs".localized()): \(wsScheme)\(serverAddr)\(texts[2])"
//                                
//                return 
//                var temp: String = loginServerAddressTextField.text!
//                
//                if temp.hasSuffix(bussinessRoute) {
//                    loginServerAddressTextField.text = temp.replacingOccurrences(of: bussinessRoute, with: texts[0])
//                } else {
//                    loginServerAddressTextField.text = temp.replacingOccurrences(of: bussinessPort, with: texts[0])
//                }
//                
//                temp = imApiServerAddressTextField.text!
//                
//                if temp.hasSuffix(sdkAPIRoute) {
//                    imApiServerAddressTextField.text = temp.replacingOccurrences(of: sdkAPIRoute, with: texts[1])
//                } else {
//                    imApiServerAddressTextField.text = imApiServerAddressTextField.text?.replacingOccurrences(of: sdkAPIPort, with: texts[1])
//                }
//                
//                temp = imWSServerAddressTextField.text!
//                
//                if temp.hasSuffix(sdkWSRoute) {
//                    imWSServerAddressTextField.text = temp.replacingOccurrences(of: sdkWSRoute, with: texts[2])
//                } else {
//                    imWSServerAddressTextField.text = imWSServerAddressTextField.text?.replacingOccurrences(of: sdkWSPort, with: texts[2])
//                }
//            })
//            .disposed(by: disposeBag)
        
//        serverAddressTextField.rx.text
//            .orEmpty
//            .map { [weak self] address in
//                guard let self else { return "" }
//                
//                let scheme = enableTSL ? "https://" : "http://"
//                let route = enableRoute ? bussinessRoute : bussinessPort
//                
//                return "\(scheme)\(address)\(route)"
//            }
//            .bind(to: loginServerAddressTextField.rx.text)
//            .disposed(by: disposeBag)
        
//        serverAddressTextField.rx.text
//            .orEmpty
//            .map { [weak self] address in
//                guard let self else { return "" }
//                
//                let scheme = enableTSL ? "https://" : "http://"
//                let route = enableRoute ? sdkAPIRoute : sdkAPIPort
//                
//                return "\(scheme)\(address)\(route)"
//            }
//            .bind(to: imApiServerAddressTextField.rx.text)
//            .disposed(by: disposeBag)
//        
//        serverAddressTextField.rx.text
//            .orEmpty
//            .map { [weak self] address in
//                guard let self else { return "" }
//                
//                let scheme = enableTSL ? "wss://" : "ws://"
//                let route = enableRoute ? sdkWSRoute : sdkWSPort
//                
//                return "\(scheme)\(address)\(route)"
//            }
//            .bind(to: imWSServerAddressTextField.rx.text)
//            .disposed(by: disposeBag)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
