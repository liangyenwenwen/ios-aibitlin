
import OUICore
import OUICoreView
import RxSwift
import SnapKit

class PermissionUserListViewController: UIViewController {
    
    private lazy var _tableView: UITableView = {
        let v = UITableView()
        v.register(FriendListUserTableViewCell.self, forCellReuseIdentifier: FriendListUserTableViewCell.className)
        v.dataSource = self
        v.delegate = self
        v.rowHeight = UITableView.automaticDimension
        v.separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: StandardUI.margin_22)
        v.separatorColor = .cF1F1F1
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        v.tableFooterView = UIView()
        
        return v
    }()
    
    private let _disposeBag = DisposeBag()
    
    var users: [ContactInfo]!
    
    init(users: [ContactInfo]) {
        super.init(nibName: nil, bundle: nil)
        self.users = users
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "部分好友可见".innerLocalized()
        initView()
    }
    
    private func initView() {
        view.addSubview(_tableView)
        _tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    
    deinit {
        print("dealloc \(type(of: self))")
    }
}

extension PermissionUserListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendListUserTableViewCell.className) as! FriendListUserTableViewCell
        let user = users[indexPath.row]
        cell.titleLabel.text = user.name
        cell.avatarImageView.setAvatar(url: user.faceURL, text: user.name)
        
        return cell
    }
}
