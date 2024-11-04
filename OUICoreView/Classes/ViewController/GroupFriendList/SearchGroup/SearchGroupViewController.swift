import RxSwift
import OUICore
import ProgressHUD

public class SearchGroupViewController: UIViewController {
    
    public var didSelectedItem: ((_ groupID: String) -> Void)?
    lazy var resultViewController: SearchResultViewController = {
        let r = SearchResultViewController(searchType: .group)
        return r
    }()
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        definesPresentationContext = true
//        navigationItem.title = "addGroup".innerLocalized()
        navigationItem.title = "ID"

        
        let searchViewController = UISearchController(searchResultsController: resultViewController)
//        searchViewController.searchResultsUpdater = resultViewController
        searchViewController.searchBar.placeholder = "searchIDAddGroup".innerLocalized()
        searchViewController.obscuresBackgroundDuringPresentation = false
        searchViewController.hidesNavigationBarDuringPresentation = false
        searchViewController.automaticallyShowsCancelButton = false
        searchViewController.delegate = self
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
        ProgressHUD.dismiss()
//        view.endEditing(true)
    }
    @objc func showKeyboard() {
        navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
}
extension SearchGroupViewController: UISearchBarDelegate{
    //点击搜索按钮
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.resultViewController.searchBarSearchButtonClicked(searchBar)

    }
}
extension SearchGroupViewController: UISearchControllerDelegate {
    public func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
        }
    }
}
