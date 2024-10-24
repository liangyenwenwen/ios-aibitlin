
import OUICore
import IGListKit
import IGListDiffKit
import FDFullscreenPopGesture
import SnapKit

extension Notification.Name {
    struct list {
        // The comment list of collectionview is positioned to the current notification
        static let contentOffset = Notification.Name("list-contentOffset")
    }
}

public class BaseIGListViewController: UIViewController {
    
    var objects: [ListDiffable] = [ListDiffable]()
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let v = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        
        if #available(iOS 11.0, *) {
            v.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        v.backgroundColor = .clear
                
        return v
    }()
    
    lazy var adapter: ListAdapter = {
        let adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: self)
        return adapter
    }()

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        self.fd_prefersNavigationBarHidden = true
        self.modalPresentationCapturesStatusBarAppearance = false
        
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
        
        collectionView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(-(UIApplication.safeAreaInsets.top + UIApplication.statusBarHeight))
//            make.top.equalTo(222.h)
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        UIApplication.shared.keyWindow?.endEditing(true)
    }
}

// MARK: - <ListAdapterDataSource>
extension BaseIGListViewController : ListAdapterDataSource {
    
    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return objects
    }
    
    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return ListSectionController()
    }
    
    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
