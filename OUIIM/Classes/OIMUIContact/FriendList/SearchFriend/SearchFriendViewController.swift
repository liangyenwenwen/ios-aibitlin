
import RxSwift
import OUICore
import OUICoreView

class SearchFriendViewController: UIViewController {
    
    var didSelectedItem: ((_ ID: String) -> Void)?
    lazy var resultViewController: SearchResultViewController = {
        let r = SearchResultViewController(searchType: .user)
        return r
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        definesPresentationContext = true
//        navigationItem.title = "addFriend".innerLocalized()
        navigationItem.title = "搜索联系人".localized()
        
        navigationController!.navigationBar.backItem?.title = ""
        
//        let resultViewController = SearchResultViewController(searchType: .user)
        let searchViewController = UISearchController(searchResultsController: resultViewController)
        searchViewController.searchResultsUpdater = resultViewController
        searchViewController.searchBar.placeholder = "addFriendHint".innerLocalized()
        searchViewController.obscuresBackgroundDuringPresentation = false
        searchViewController.hidesNavigationBarDuringPresentation = false
        searchViewController.automaticallyShowsCancelButton = false
        searchViewController.dimsBackgroundDuringPresentation = false
//        searchViewController.delegate = self
        searchViewController.searchBar.delegate = self

        navigationItem.searchController = searchViewController
        navigationItem.hidesSearchBarWhenScrolling = false
        resultViewController.didSelectedItem = didSelectedItem
        self.perform(#selector(self.showKeyboard), with:nil, afterDelay:0.1)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.searchController?.isActive = true
        
        navigationController?.navigationBar.isHidden = false
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
    }
    @objc func showKeyboard() {
        navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
}
extension SearchFriendViewController: UISearchBarDelegate{
    //点击搜索按钮
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.resultViewController.searchBarSearchButtonClicked(searchBar)

    }
}
extension SearchFriendViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
        }
    }
}
