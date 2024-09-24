
import RxDataSources
import RxSwift
import OUICore
import OUICoreView

class UnreadListViewController: UIViewController {
    
    private var _viewModel: UnreadListViewModel!
    
    init(conversationID: String, clientMsgID: String) {
        super.init(nibName: nil, bundle: nil)
        _viewModel = UnreadListViewModel(conversationID: conversationID, clientMsgID: clientMsgID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "消息阅读状态".innerLocalized()
        view.backgroundColor = .viewBackgroundColor
        initView()
        bindData()
        _viewModel.getReadStatusMembers()
    }

    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: FriendListUserTableViewCell.className)
        v.separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: StandardUI.margin_22)
        v.separatorColor = .sepratorColor
        v.rowHeight = UITableView.automaticDimension
        v.backgroundColor = .clear
        
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        v.tableFooterView = UIView()
        
        return v
    }()

    private let iHasReadedBtn: UnderlineButton = {
        let v = UnderlineButton(frame: .zero)
        v.setTitle("hasRead".innerLocalized(), for: .normal)
        v.setTitleColor(.c0C1C33, for: .normal)
        v.titleLabel?.font = .f14
        v.isSelected = true
        v.underLineWidth = 30
        return v
    }()

    private let iUnreadBtn: UnderlineButton = {
        let v = UnderlineButton(frame: .zero)
        v.setTitle("unread".innerLocalized(), for: .normal)
        v.setTitleColor(.c0C1C33, for: .normal)
        v.titleLabel?.font = .f14
        v.underLineWidth = 30
        return v
    }()

    private lazy var resultC = UnreadListResultViewController()

    private func initView() {
        let searchC: UISearchController = {
            let v = UISearchController(searchResultsController: resultC)
            v.searchResultsUpdater = resultC
            v.searchBar.placeholder = "搜索".innerLocalized() + ":" + "昵称".innerLocalized()
            v.obscuresBackgroundDuringPresentation = true

            return v
        }()
//        navigationItem.searchController = searchC
        let btnStackView: UIStackView = {
            let v = UIStackView(arrangedSubviews: [iUnreadBtn, iHasReadedBtn])
            v.frame = CGRect(origin: .zero, size: CGSize(width: kScreenWidth, height: 44))
            v.axis = .horizontal
            v.distribution = .fillEqually
            v.backgroundColor = .cellBackgroundColor
            
            return v
        }()
        
        view.addSubview(btnStackView)
        btnStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }

        let line = UIView()
        line.backgroundColor = .sepratorColor
        view.addSubview(line)
        
        line.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(btnStackView.snp.bottom)
            make.height.equalTo(1)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(line.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }

    private let _disposeBag = DisposeBag()
    private func bindData() {
        iHasReadedBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self else { return }
            
            _viewModel.isHasReadTableSelected.accept(true)
        }).disposed(by: _disposeBag)
        
        _viewModel.hasReadCountRelay.subscribe(onNext: { [weak self] count in
            guard let self else { return }
            
            iHasReadedBtn.setTitle("hasRead".innerLocalized() + "(\(count))", for: .normal)
        }).disposed(by: _disposeBag)

        _viewModel.unReadCountRelay.subscribe(onNext: { [weak self] count in
            guard let self else { return }
            
            iUnreadBtn.setTitle("unread".innerLocalized() + "(\(count))", for: .normal)
        }).disposed(by: _disposeBag)
        
        iUnreadBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?._viewModel.isHasReadTableSelected.accept(false)
        }).disposed(by: _disposeBag)

        _viewModel.isHasReadTableSelected
            .bind(to: iHasReadedBtn.rx.isSelected)
            .disposed(by: _disposeBag)

        _viewModel.isHasReadTableSelected
            .map { !$0 }
            .bind(to: iUnreadBtn.rx.isSelected)
            .disposed(by: _disposeBag)

        _viewModel.items.bind(to: tableView.rx.items(cellIdentifier: FriendListUserTableViewCell.className, cellType: FriendListUserTableViewCell.self)) { _, model, cell in
            cell.titleLabel.text = model.nickname
            cell.avatarImageView.setAvatar(url: model.faceURL, text: model.nickname, onTap: nil)
        }.disposed(by: _disposeBag)

        _viewModel.items
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] ms in
                self?.resultC.dataList = ms
            }).disposed(by: _disposeBag)
    }
}
