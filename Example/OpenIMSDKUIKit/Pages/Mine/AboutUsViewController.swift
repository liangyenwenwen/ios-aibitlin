import UIKit
import OUICore
import ProgressHUD
import SnapKit

class AboutUsViewController: UIViewController {
    
    public static var version: String {
        let infoDictionary = Bundle.main.infoDictionary
        let displayName = infoDictionary!["CFBundleDisplayName"] as! String
        let majorVersion = infoDictionary!["CFBundleShortVersionString"] as! String //主程序版本号
        var minorVersion = infoDictionary!["CFBundleVersion"] as! String //版本号（内部标示）

        let SDKVersion = "3.5.1-e-1.1.4"
        let info = "\(displayName):\(majorVersion)+\(minorVersion) SDK \(SDKVersion)"
        
        return info
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo_image")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var aboutLabel: UILabel = {
        let label = UILabel()
        label.text = Self.version
        label.textAlignment = .center
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var uploadLogButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.setTitle("上传日志".localized(), for: .normal)
        button.titleLabel?.textAlignment = .left
        button.addTarget(self, action: #selector(handleUploadLogsAction(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .left

        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "关于我们".localized()
        view.backgroundColor = .viewBackgroundColor
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(logoImageView)
        containerView.addSubview(aboutLabel)
        containerView.addSubview(uploadLogButton)
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(8) // 设置边距为8
            make.bottom.equalTo(uploadLogButton).offset(8)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(16)
            make.centerX.equalTo(containerView)
            make.width.height.equalTo(100)
        }
        
        aboutLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(16)
            make.centerX.equalTo(containerView)
        }
        
        let line = UIView()
        line.backgroundColor = .sepratorColor
        
        containerView.addSubview(line)
        line.snp.makeConstraints { make in
            make.top.equalTo(aboutLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        uploadLogButton.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom)
            make.height.equalTo(60)
            make.leading.equalTo(containerView).offset(16)
        }
        
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.forward"))
        arrowImageView.tintColor = .black
        arrowImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        containerView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.leading.equalTo(uploadLogButton.snp.trailing)
            make.centerY.equalTo(uploadLogButton)
            make.trailing.equalTo(containerView).inset(16)
        }
    }
    
    @objc
    private func handleUploadLogsAction(_ sender: UIButton) {
        ProgressHUD.animate()
        
        IMController.shared.uploadLogs(onProgress: { p in
            ProgressHUD.progress(p)
        }, onSuccess: { _ in
            ProgressHUD.success()
        }, onFailure: { errCode, errMsg in
            ProgressHUD.dismiss()
        })
    }
    
}
