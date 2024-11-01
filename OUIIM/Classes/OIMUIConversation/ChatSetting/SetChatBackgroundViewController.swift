import OUICore
import Photos
import ProgressHUD
import RxSwift

class SetChatBackgroundViewController: UIViewController {
    
    private var conversationID: String!
    
    init(conversationID: String) {
        super.init(nibName: nil, bundle: nil)
        self.conversationID = conversationID
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
        v.setConfigToPickBackground()
        v.didPhotoSelected = { [weak self, weak v] (images: [UIImage], assets: [PHAsset]) in
            guard let self else { return }
            
            ProgressHUD.animate()
            for (index, asset) in assets.enumerated() {
                switch asset.mediaType {
                case .image:
                    if let t = images[index].pngData(), let temp = UIImage(data: t) {
                        image = temp
                        ProgressHUD.dismiss()
                        saveChatBackground()
                    }
                default:
                    break
                }
            }
        }
        
        v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
            guard let self else { return }
    
            ProgressHUD.animate()
            if let photo {
                image = photo
                ProgressHUD.dismiss()
                saveChatBackground()
            }
        }
        return v
    }()
    
    private let disposeBag = DisposeBag()
    private var image: UIImage?
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "setChatBackground".innerLocalized()
        view.backgroundColor = .viewBackgroundColor
        
        setupSubviews()
    }
    
    private func setupSubviews() {
        let contentView = UIView()
        contentView.backgroundColor = .cellBackgroundColor
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        let abulm = configCell(title: "selectAssetsFromAlbum".innerLocalized()) { [weak self] in
            guard let self else { return }
            
            _photoHelper.presentPhotoLibrary(byController: self)
        }

        let camera = configCell(title: "selectAssetsFromCamera".innerLocalized()) { [weak self] in
            guard let self else { return }
            
            _photoHelper.presentCamera(byController: self)
        }

        let `default` = configCell(title: "useDefaultBackground".innerLocalized()) { [weak self] in
            guard let self else { return }
            image = nil
            saveChatBackground()
        }

        let vStack = UIStackView(arrangedSubviews: [abulm, camera, `default`])
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        
        contentView.addSubview(vStack)
        
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        view.layoutIfNeeded()
        let maskPath = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 6, height: 6))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        contentView.layer.mask = shape
    }
    
    private func configCell(title: String, onTap:(() -> Void)?) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = .f17
        titleLabel.textColor = .c0C1C33
        titleLabel.text = title
        titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        let arrowImageView = UIImageView(image: UIImage(nameInBundle: "common_arrow_right"))

        let contentView = UIView()
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.height.equalTo(12)
            make.width.equalTo(6)
        }
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            onTap?()
        }).disposed(by: disposeBag)
        
        contentView.addGestureRecognizer(tap)
        contentView.isUserInteractionEnabled = true
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(46.h)
        }
        
        return contentView
    }
    
    private func saveChatBackground() {
        guard let conversationID else { return }
        
        let name = "chat_bg_\(conversationID).png"
        
        if let image {
            FileHelper.shared.saveImage(image: image, name: name)
        } else {
            if let path = FileHelper.shared.exsit(path: "", name: name) {
                FileHelper.shared.removeFile(path: path)
            }
        }
        
        if let chat = navigationController?.children.first(where: { $0 is ChatViewController }) {
            navigationController?.popToViewController(chat, animated: true)
        }
    }
}
