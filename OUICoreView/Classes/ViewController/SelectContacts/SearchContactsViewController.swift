
import Foundation
import UIKit
import OUICore
import RxSwift
import ProgressHUD

class SearchContactsViewController: UIViewController {

    var dataList: [ContactInfo] = [] {
       didSet {
           for user in dataList {
               if let ret: [WPFPerson] = WPFPinYinDataManager.getInitializedDataSource() as? [WPFPerson] {
                   if !ret.contains(where: { (item: WPFPerson) in
                       item.personId == user.ID
                   }) {
                       WPFPinYinDataManager.addInitializeString(user.name, sub: user.sub, identifer: user.ID)
                   }
               } else {
                   WPFPinYinDataManager.addInitializeString(user.name, sub: user.sub, identifer: user.ID)
               }
           }
       }
   }
   
   var selectedUsers: [ContactInfo] = []
   
   var removeUsersCallback: (([ContactInfo]) -> Void)!
   var selectedCallback: (([ContactInfo]) -> Void)!
   var removeUsers: [ContactInfo] = []
        
    private var enableChangeSelectedModel = false
    private var allowsMultipleSelection = true
        
    public init(enableChangeSelectedModel: Bool = false, allowsMultipleSelection: Bool = true, selectedCallback: @escaping ([ContactInfo]) -> Void, removeCallback: @escaping ([ContactInfo]) -> Void) {
       super.init(nibName: nil, bundle: nil)
       self.removeUsersCallback = removeCallback
       self.selectedCallback = selectedCallback
        self.enableChangeSelectedModel = enableChangeSelectedModel
        self.allowsMultipleSelection = enableChangeSelectedModel ? false : allowsMultipleSelection
   }
   
   required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
   }
   
   private var searchArr: [WPFPerson] = []

   private lazy var tableView: UITableView = {
       let v = UITableView()
       v.register(SelectUserTableViewCell.self, forCellReuseIdentifier: SelectUserTableViewCell.className)
       v.dataSource = self
       v.delegate = self
       v.separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: StandardUI.margin_22)
       v.separatorColor = .sepratorColor
       v.rowHeight = UITableView.automaticDimension
       v.allowsMultipleSelection = true
       v.backgroundColor = .clear
       v.keyboardDismissMode = .onDrag
       
       if #available(iOS 15.0, *) {
           v.sectionHeaderTopPadding = 0
       }

       return v
   }()
    
    lazy var searchController: UISearchController = {
        let v = UISearchController(searchResultsController: nil)
        v.hidesNavigationBarDuringPresentation = false
        v.dimsBackgroundDuringPresentation = false
        v.searchBar.searchBarStyle = .prominent
        v.searchBar.sizeToFit()
        v.searchResultsUpdater = self
        v.automaticallyShowsCancelButton = false
        v.hidesNavigationBarDuringPresentation = false
        
        return v
    }()
    
    private let _viewModel = SelectContactsViewModel()
    private var resultVC: SelectContactsResultViewController!
    private let _disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .viewBackgroundColor
        navigationItem.title = "搜索".innerLocalized()
        if enableChangeSelectedModel {
            let tipsLabel = UILabel()
            tipsLabel.text = "searchResult".innerLocalized()
            tipsLabel.font = .f14
            tipsLabel.textColor = .c8E9AB0
            
            let changeButton = UIButton(type: .custom)
            changeButton.setTitle("menuMulti".innerLocalized(), for: .normal)
            changeButton.setTitle("endMulti".innerLocalized(), for: .selected)
            changeButton.setTitleColor(.c0089FF, for: .normal)
            changeButton.titleLabel?.font = .f14
            
            changeButton.rx.tap.subscribe(onNext: { [weak self] _ in
                changeButton.isSelected = !changeButton.isSelected
                self?.allowsMultipleSelection = changeButton.isSelected
                
                if !changeButton.isSelected {
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.tableView.reloadData()
                }
            }).disposed(by: _disposeBag)
            
            let hStack = UIStackView(arrangedSubviews: [tipsLabel, UIView(), changeButton])
            
            let hBackground = UIView()
            hBackground.backgroundColor = .systemBackground
            
            hBackground.addSubview(hStack)
            hStack.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(16)
                make.top.bottom.equalToSuperview()
            }
            
            let vStack = UIStackView(arrangedSubviews: [hBackground, tableView])
            vStack.axis = .vertical
            
            view.addSubview(vStack)
            vStack.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            }
        } else {
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            }
        }
        navigationItem.searchController = searchController
        WPFPinYinDataManager.shareInstance().clearDataSource()
        _viewModel.searchResult.subscribe(onNext: { [weak self] r in
            self?.dataList = r
            self?.updateSearchResults(text: self?.searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines))
        }).disposed(by: _disposeBag)
        getMyFriendList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        definesPresentationContext = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ProgressHUD.dismiss()
        definesPresentationContext = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async { [self] in
            searchController.searchBar.becomeFirstResponder()
        }
    }
    func getMyFriendList() {
        IMController.shared.getFriendList { [weak self] users in
            let userPrefix = ":user_"
            let r = users.compactMap({ ContactInfo(ID: userPrefix + $0.userID!, name: $0.showName,faceURL: $0.faceURL) })
            for user in r {
                if let ret: [WPFPerson] = WPFPinYinDataManager.getInitializedDataSource() as? [WPFPerson] {
                    if !ret.contains(where: { (item: WPFPerson) in
                        item.personId == user.ID
                    }) {
                        WPFPinYinDataManager.addInitializeString(user.name, identifer:user.ID!)
                    }
                    } else {
                        WPFPinYinDataManager.addInitializeString(user.name, identifer: user.ID!)
                    }
            }
        }
    }
    
    public func updateSearchResults(text: String?) {
        searchArr.removeAll()
        guard let keyword = text else { return }
        guard let arr = WPFPinYinDataManager.getInitializedDataSource() as? [WPFPerson] else { return }
        for person in arr {
            if let result = WPFPinYinTools.searchEffectiveResult(withSearch: keyword, person: person) {
                if result.highlightedRange.length > 0 {
                    person.highlightLoaction = result.highlightedRange.location
                    person.textRange = result.highlightedRange
                    person.matchType = Int(result.matchType.rawValue)
                    if let personId = person.personId {
                        var userId = personId.replacingOccurrences(of: "user_", with: "")
                        userId = userId.replacingOccurrences(of: ":", with: "")
                        person.personId = userId
                    }
                    searchArr.append(person)
                }
            }
        }
        let change = searchArr
        searchArr = change.sorted { lhs, rhs in
            lhs.matchType < rhs.matchType
        }.sorted { lhs, rhs in
            lhs.highlightLoaction < rhs.highlightLoaction
        }

        tableView.reloadData()
    }
}

extension SearchContactsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let keyword = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            _viewModel.search(keyword: keyword, type: [.friends])
        }
    }
}

extension SearchContactsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return searchArr.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectUserTableViewCell.className, for: indexPath) as! SelectUserTableViewCell
        let person = searchArr[indexPath.row]
        let attString = NSMutableAttributedString(string: person.name)
        let highLightColor = UIColor.blue
        attString.addAttribute(NSAttributedString.Key.foregroundColor, value: highLightColor, range: person.textRange)
        cell.titleLabel.attributedText = attString
        cell.subtitleLabel.text = person.sub
        
        cell.showSelectedIcon = allowsMultipleSelection
        
        if let user = dataList.first(where: { $0.ID == person.personId }) {
            cell.avatarImageView.setAvatar(url: user.faceURL, text: user.name)
        }
        
        if selectedUsers.contains(where: { $0.ID == person.personId }) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = searchArr[indexPath.row]
        let user = dataList.first { $0.ID == person.personId }
        if user != nil {
            selectedCallback([user!])
        }
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let person = searchArr[indexPath.row]
        let user = dataList.first { $0.ID == person.personId }
        if user != nil {
            removeUsersCallback([user!])
        }
    }
}
