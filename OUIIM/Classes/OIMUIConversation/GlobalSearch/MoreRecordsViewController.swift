import Foundation
import RxSwift
import OUICore
import OUICoreView

class MoreRecordsViewController: UIViewController {
    
    private var showName: String?
    private var faceURL: String?
    private var conversationID: String!
    private var searchText: String?

    init(result: SearchResultItemInfo, conversationID: String, searchText: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.conversationID = conversationID
        self.searchText = searchText
        showName = result.showName
        faceURL = result.faceURL
        viewModel.textRelay.accept([result])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let disposeBag = DisposeBag()
    
    private let avatarView = AvatarView()
    
    private lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        
        return v
    }()
    
    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(MessageRecordTableViewCell.self, forCellReuseIdentifier: MessageRecordTableViewCell.className)
        v.rowHeight = 64
        v.tableFooterView = UIView()
        v.keyboardDismissMode = .onDrag
        v.delegate = self
        v.dataSource = self
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        
        return v
    }()
    
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
    
    private let viewModel = GlobalSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        
        setupSubviews()
        bindData()
    }
    
    private func setupSubviews() {
        
        navigationItem.titleView = searchBar
        
        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .systemGray4
        arrow.contentMode = .center
        
        let header = UIView()
        header.layer.cornerRadius = 5
        header.layer.masksToBounds = true
        header.backgroundColor = .cellBackgroundColor
        header.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer()
        header.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            self?.toChatView()
        }).disposed(by: disposeBag)
        
        let hStack = UIStackView(arrangedSubviews: [avatarView, nameLabel, UIView(), arrow])
        hStack.spacing = 8
        hStack.alignment = .center
        
        header.addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func bindData() {
        avatarView.setAvatar(url: faceURL, text: showName)
        nameLabel.text = showName
        searchBar.text = searchText
        searchBar.rx.text.changed.subscribe(onNext: { [weak self] text in
            if let text, text.isEmpty, let self { // Clear the input box response.
                viewModel.searchText(query: text, conversationID: conversationID)
            }
        }).disposed(by: disposeBag)

        searchBar.rx.searchButtonClicked.subscribe(onNext: { [weak self] in
            self?.searchBar.searchTextField.resignFirstResponder()
            
            if let text = self?.searchBar.text, let self {
                viewModel.searchText(query: text, conversationID: conversationID)
            }
        }).disposed(by: disposeBag)
        
        viewModel.textRelay.subscribe(onNext: { [weak self] _ in
            self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    }
    
    func toChatView(anchorMessage: MessageInfo? = nil) {
        IMController.shared.getConversation(conversationID: conversationID!) { [weak self] (conversation: ConversationInfo?) in
            guard let self, let conversation else { return }
            
            if let anchorMessage {
                let vc = ChatViewControllerBuilder().build(conversation, anchorMessage: anchorMessage, hiddenInputBar: true)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = ChatViewControllerBuilder().build(conversation)
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
                if let root = navigationController?.viewControllers.first {
                    navigationController?.viewControllers.removeAll(where: { controller in
                        controller != root && controller != vc
                    })
                }
            }
        }
    }
}

extension MoreRecordsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.textRelay.value.first?.messageCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageRecordTableViewCell.className, for: indexPath) as! MessageRecordTableViewCell
        
        let msg = viewModel.textRelay.value.first!.messageList[indexPath.row]
        
        cell.avatarView.setAvatar(url: msg.senderFaceUrl, text: msg.senderNickname)
        cell.nameLabel.text = msg.senderNickname
        cell.contentLabel.text = msg.textElem?.content
        cell.timeLabel.text = Date.timeString(timeInterval: msg.sendTime / 1000)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let msg = viewModel.textRelay.value.first!.messageList[indexPath.row]

        toChatView(anchorMessage: msg)
    }
}
