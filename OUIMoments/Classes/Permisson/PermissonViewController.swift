
import OUICore
import OUICoreView
import SnapKit
import RxSwift

enum PermissionType: Int, CaseIterable {
    case `public` = 0
    case `private` = 1
    case part = 2
    case block = 3
    
    var title: String {
        switch self {
        case .`public`:
            return "公开".innerLocalized()
        case .`private`:
            return "私密".innerLocalized()
        case .part:
            return "部分可见".innerLocalized()
        case .block:
            return "不给谁看".innerLocalized()
        }
    }
    
    var subTitle: String {
        switch self {
        case .`public`:
            return "所有人可见".innerLocalized()
        case .`private`:
            return "仅自己可见".innerLocalized()
        case .part:
            return "选中的人可见".innerLocalized()
        case .block:
            return "选中的人不可见".innerLocalized()
        }
    }
}

class PermissonViewController: UIViewController {
    
    private struct ItemInfo {
        var type: PermissionType = .private
        var canExpand: Bool = false
        var isExpand: Bool = false
        var data: [[ContactInfo]] = [[], []] // 部分/屏蔽 的section有两个row（从好友选择/从群组选择）
    }

    private var items: [ItemInfo] = []
    private var selectedIndexPath: IndexPath? // 当前选中的行
    
    var selectedItemsHandler:((_ type: PermissionType, _ friends: [ContactInfo], _ groups: [ContactInfo]) -> Void)?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(PermissonCell.self, forCellReuseIdentifier: NSStringFromClass(PermissonCell.self))
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "权限设置".innerLocalized()
        
        items.append(ItemInfo(type: .public))
        items.append(ItemInfo(type: .private))
        items.append(ItemInfo(type: .part,
                              canExpand: true))
        items.append(ItemInfo(type: .block,
                              canExpand: true))
        setupView()
    }
    
    func setupView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let completButton = UIBarButtonItem(title: "完成".innerLocalized(), style: .done, target: self, action: #selector(completion))
        navigationItem.setRightBarButton(completButton, animated: false)
    }
    
    @objc func completion() {
        
        let i = items.first(where: {$0.isExpand})
        
        if let item = i, ((item.type == .part || item.type == .block) && item.data.flatMap({!$0.isEmpty}).isEmpty) {
            presentAlert(title: "至少选择一个朋友或群组".innerLocalized())
        } else {
            if let handler = selectedItemsHandler, let s = selectedIndexPath {
                let item = items[s.section]
                let friends = item.data.first!.filter({ $0.type == .user })
                let groups = item.data.first!.filter({ $0.type == .group })
                handler(item.type, friends, groups)
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func getDisplayString(friends: Bool = true, _ indexPath: IndexPath) -> String? {
        let i = items[indexPath.section].data[indexPath.row - 1]
        var j = i.map {$0.name!}.joined(separator: "、")
        
        return j
    }
    
    private func selectContacts(friends: Bool = true, _ indexPath: IndexPath) {
        
        let vc = MyContactsViewController(multipleSelected: true)
        vc.selectedContact(hasSelected: items[indexPath.section].data[indexPath.row - 1]) { [weak self] result in
   
            self?.items[indexPath.section].data[indexPath.row - 1] = result
            self?.tableView.performBatchUpdates {
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            self?.navigationController?.popViewController(animated: true)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateData(indexPath: IndexPath) {
        
        // 1. 上一行重置
        if let sip = selectedIndexPath {
            let cell = tableView.cellForRow(at: sip) as! PermissonCell
            cell.checkBox.isSelected = false
            cell.rightImageView.image = UIImage.init(nameInBundle: "moments_arrow_right")
        }
        
        // 1.1 选中的行，checkbox = ture
        let cell = tableView.cellForRow(at: indexPath) as! PermissonCell
        cell.checkBox.isSelected = true
        cell.rightImageView.image = UIImage.init(nameInBundle: "moments_arrow_down")
        
        // 2. 如果是可以展开的行，调整展开状态
        var item = items[indexPath.section]
        
        // 2.1 插入当前indexpath的cell/删除其它cell
        var insertIndexPath: [IndexPath]?
        var deleteIndexPath: [IndexPath]?
        
        if item.canExpand {
            if (!item.isExpand) {
                // 需要展开
                insertIndexPath = [.init(row: 1, section: indexPath.section), .init(row: 1, section: indexPath.section)]
                // 如果上一行成展开状态
                if let sip = selectedIndexPath, items[sip.section].isExpand {
                    deleteIndexPath = [.init(row: 1, section: sip.section), .init(row: 1, section: sip.section)]
                }
            } else {
                // 点击行关闭
                deleteIndexPath = [.init(row: 1, section: indexPath.section), .init(row: 1, section: indexPath.section)]
            }
        } else {
            // 如果上一行成展开状态
            if let sip = selectedIndexPath, items[sip.section].isExpand {
                deleteIndexPath = [.init(row: 1, section: sip.section), .init(row: 1, section: sip.section)]
            }
        }
        
        // 3. 把数据源的所有状态重置下
        for(i, item) in items.enumerated() {
            if item.canExpand {
                // 重复点击当前行
                items[i].isExpand = (i == selectedIndexPath?.section && item.isExpand) ? false : (i == indexPath.section)
            }
        }
        
        // 4. 刷新section
        tableView.performBatchUpdates {
            if let dip = deleteIndexPath {
                tableView.deleteRows(at: dip, with: .automatic)
            }
            if let iip = insertIndexPath {
                tableView.insertRows(at: iip, with: .automatic)
            }
        }
        
        selectedIndexPath = indexPath
    }
    
}

extension PermissonViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = items[section]
        if !item.isExpand || !item.canExpand {
            return 1
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PermissonCell.self), for: indexPath) as! PermissonCell
        let item = items[indexPath.section]
        
        if indexPath.row == 0 {
            // 带选中标记的第一行
            cell.subButton.isHidden = true
            cell.titleLabel.text = item.type.title
            cell.subTitleLabel.text = item.type.subTitle
            cell.checkBox.isSelected = item.isExpand
            cell.rightImageView.isHidden = !item.canExpand
            cell.subTitleLabel.textColor = .systemGray3
        } else if indexPath.row == 1 {
            // 从好友选
            cell.rightImageView.isHidden = true
            cell.subTitleLabel.text = getDisplayString(indexPath)
            cell.subTitleLabel.textColor = .systemBlue
            cell.subButton.isHidden = false
            cell.subButton.setTitle("从通讯录选择".innerLocalized(), for: .normal)
            cell.onTapButton = { [weak self] in
                self?.selectContacts(indexPath)
            }
        }
        
        return cell
    }
    
    //MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            updateData(indexPath: indexPath)
        } else {
            
        }
    }
}

class PermissonCell: UITableViewCell {
    
    let disposeBag = DisposeBag()
    
    lazy var checkBox: UIButton = {
        let v = UIButton(type: .custom)
        v.setBackgroundImage(nil, for: .normal)
        v.setBackgroundImage(UIImage(nameInBundle: "moments_permisson_selected_icon"), for: .selected)
        v.snp.makeConstraints { make in
            make.size.equalTo(30)
        }
        return v
    }()
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        v.font = .systemFont(ofSize: 17)
        return v
    }()
    
    lazy var subTitleLabel: UILabel = {
        let v = UILabel()
        v.numberOfLines = 0
        v.font = .systemFont(ofSize: 14)
        return v
    }()
    
    lazy var rightImageView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage.init(nameInBundle: "moments_arrow_right")
        v.contentMode = .center
        v.snp.makeConstraints { make in
            make.size.equalTo(10)
        }
        
        return v
    }()
    
    lazy var subButton: UIButton = {
        let v = UIButton(type: .system)
        v.rx.tap.subscribe { [weak self] _ in
            self?.onTapButton?()
        }.disposed(by: disposeBag)
        return v
    }()
    
    var onTapButton: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let verSV = UIStackView(arrangedSubviews: [SizeBox(height: 8), titleLabel, subButton, subTitleLabel, SizeBox(height: 8)])
        verSV.axis = .vertical
        verSV.alignment = .leading
        verSV.spacing = 4
        
        let horSV = UIStackView(arrangedSubviews: [checkBox, verSV, rightImageView, SizeBox(width: 16)])
        horSV.spacing = 8
        horSV.alignment = .center
        contentView.addSubview(horSV)
        
        horSV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
