
import RxSwift
import OUICore
import ProgressHUD

class SearchFriendViewController: UIViewController {
    
    var didSelectedItem: ((_ userID: String) -> Void)?
    lazy var resultViewController: SearchResultViewController = {
        let r = SearchResultViewController(searchType: .user)
        return r
    }()
    var searchC: UISearchController!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        searchC = {
            let v = UISearchController(searchResultsController: resultViewController)
            v.searchResultsUpdater = resultViewController
            v.searchBar.placeholder = "addFriendHint".innerLocalized()
            v.searchBar.delegate = self

            return v
        }()
        definesPresentationContext = true
        navigationItem.searchController = searchC
        self.perform(#selector(self.showKeyboard), with:nil, afterDelay:0.1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchC.isActive = true
    }
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            ProgressHUD.dismiss()
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
