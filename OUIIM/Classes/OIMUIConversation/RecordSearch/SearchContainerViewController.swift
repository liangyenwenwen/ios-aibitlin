
import RxSwift
import OUICore
import ProgressHUD

class SearchContainerViewController: UIViewController {
    private lazy var searchBar: UISearchBar = {
        let v = UISearchBar()
        v.searchBarStyle = .minimal
        v.showsCancelButton = false
        if #available(iOS 13.0, *) {
            v.searchTextField.clearButtonMode = .always
        }
        v.placeholder = "搜索".innerLocalized()
        return v
    }()
    
    private lazy var cancelBtn: UIButton = {
        let v = UIButton()
        v.setTitle("取消".innerLocalized(), for: .normal)
        v.setTitleColor(.c0089FF, for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        v.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: _disposeBag)
        return v
    }()
    
    private let imageBtn: UIButton = {
        let v = UIButton()
        v.setTitle("图片".innerLocalized(), for: .normal)
        v.setTitleColor(.c0089FF, for: .normal)
        v.titleLabel?.font = .f17
        return v
    }()
    
    private let videoBtn: UIButton = {
        let v = UIButton()
        v.setTitle("视频".innerLocalized(), for: .normal)
        v.setTitleColor(.c0089FF, for: .normal)
        v.titleLabel?.font = .f17
        return v
    }()
    
    private let fileBtn: UIButton = {
        let v = UIButton()
        v.setTitle("文件".innerLocalized(), for: .normal)
        v.setTitleColor(.c0089FF, for: .normal)
        v.titleLabel?.font = .f17
        return v
    }()
    
    private lazy var _tableView: UITableView = {
        let v = UITableView()
        v.register(MessageRecordTableViewCell.self, forCellReuseIdentifier: MessageRecordTableViewCell.className)
        v.rowHeight = UITableView.automaticDimension
        v.separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: StandardUI.margin_22)
        v.separatorColor = .sepratorColor
        v.tableFooterView = UIView()
        v.backgroundColor = UIColor.white
        v.keyboardDismissMode = .onDrag
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
    
    private lazy var emptyLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c8E9AB0
        v.textAlignment = .center
        v.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        return v
    }()
    
    private lazy var emptyView: UIView = {
        let v = UIView()
        v.isHidden = true
        v.layer.masksToBounds = true
        
        let image = UIImage(nameInBundle: "search_empty_icon")
        let imageView = UIImageView(image: image)
        imageView.center = v.center
        v.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.equalTo(125.w)
            make.height.equalTo(76.h)
            make.leading.top.trailing.equalToSuperview()
        }
        v.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(22.h)
            make.centerX.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        return v
    }()
    
    
    
    private let _disposeBag = DisposeBag()
    private let _viewModel: SearchRecordViewModel
    
    init(conversation: ConversationInfo) {
        _viewModel = SearchRecordViewModel(conversation: conversation)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async { [self] in
            searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
        searchBar.resignFirstResponder()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cellBackgroundColor
        
        initView()
        bindData()
    }
    
    private let containerView: UIView = .init()
    
    private func initView() {
        navigationItem.titleView = searchBar
        
        let tipsLabel: UILabel = {
            let v = UILabel()
            v.font = .f14
            v.textColor = .c8E9AB0
            v.text = "quicklyFindChatHistory".innerLocalized()
            return v
        }()
        
        let hStack: UIStackView = {
            let v = UIStackView(arrangedSubviews: [imageBtn, videoBtn, fileBtn])
            v.axis = .horizontal
            v.spacing = 30
            v.distribution = .fillEqually
            return v
        }()
        
        containerView.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        containerView.addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.top.equalTo(tipsLabel.snp.bottom).offset(34.h)
            make.left.right.equalToSuperview().inset(40)
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32.h)
            make.left.right.equalToSuperview()
        }
        
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(85.h)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(_tableView)
        _tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func bindData() {
        searchBar.rx.text.changed.subscribe(onNext: { [weak self] (text: String?) in
            self?._viewModel.searchText(text)
        }).disposed(by: _disposeBag)
        
        searchBar.rx.searchButtonClicked.subscribe(onNext: { [weak self] in
            self?._viewModel.searchText(self?.searchBar.text)
            self?.emptyLabel.text = "notFoundChatHistory".localizedFormat(self?.searchBar.text ?? "")
        }).disposed(by: _disposeBag)
        
        searchBar.rx.text.map({ ($0 != nil && !$0!.isEmpty) }).bind(to: containerView.rx.isHidden).disposed(by: _disposeBag)
        
        imageBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let sself = self else { return }
            let vc = ImageRecordViewController(viewModel: sself._viewModel, viewType: .image)
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: _disposeBag)
        
        videoBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let sself = self else { return }
            let vc = ImageRecordViewController(viewModel: sself._viewModel, viewType: .video)
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: _disposeBag)
        
        fileBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let sself = self else { return }
            let vc = FileRecordViewController(viewModel: sself._viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: _disposeBag)
        
        _viewModel.textRelay.map { $0.isEmpty }.bind(to: _tableView.rx.isHidden).disposed(by: _disposeBag)
        _viewModel.textRelay.map({ !$0.isEmpty || (self.searchBar.text == nil || self.searchBar.text!.isEmpty) }).bind(to: emptyView.rx.isHidden).disposed(by: _disposeBag)
        
        _viewModel.textRelay.bind(to: _tableView.rx.items) { (tv, _, message: MessageInfo) in
            let cell = tv.dequeueReusableCell(withIdentifier: MessageRecordTableViewCell.className) as! MessageRecordTableViewCell
            cell.avatarView.setAvatar(url: message.senderFaceUrl, text: message.senderNickname)
            cell.nameLabel.text = message.senderNickname
            cell.contentLabel.text = message.textElem?.content
            cell.timeLabel.text = FormatUtil.getFormatDate(of: Int(message.sendTime) / 1000)
            return cell
        }.disposed(by: _disposeBag)
        
        _tableView.rx.modelSelected(MessageInfo.self).subscribe(onNext: { [weak self] (message: MessageInfo) in
            guard let self else { return }
            let conversation = self._viewModel.conversation
            let vc = ChatViewControllerBuilder().build(conversation, anchorMessage: message, hiddenInputBar: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: _disposeBag)
        
    }
}

class MessageRecordTableViewCell: UITableViewCell {
    public let avatarView = AvatarView()
    
    public let nameLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        
        return v
    }()
    
    public let contentLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c8E9AB0
        
        return v
    }()
    
    public let timeLabel: UILabel = {
        let v = UILabel()
        v.font = .f12
        v.textColor = .c8E9AB0
        
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .cellBackgroundColor
        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(StandardUI.margin_22)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10).priority(.low)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.top.equalTo(avatarView).offset(2)
            make.right.equalToSuperview().offset(-80)
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.bottom.equalTo(avatarView)
            make.right.equalToSuperview().offset(-StandardUI.margin_22)
        }
        
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-StandardUI.margin_22)
            make.centerY.equalTo(nameLabel)
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
