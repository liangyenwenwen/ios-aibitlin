
import Foundation
import OUICoreView
import RxSwift
import OUICore

class MentionViewController: SelectContactsViewController {
    
    var mentionAll: (() -> Void)?
    var vcDissmiss: (() -> Void)?
    
    private let avatarView: AvatarView = {
        let v = AvatarView()
        v.setAvatar(url: nil, text: "@")
        
        return v
    }()
    
    private let disposeBag = DisposeBag()
    
    private lazy var nameLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        v.text = "所有人".innerLocalized()
        
        return v
    }()
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.vcDissmiss?()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "群成员".innerLocalized()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(nameInBundle: "common_back_icon")) { [weak self] in
            self?.dismiss(animated: true)
        }
        
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false 
        maxCount = 10
        allowsSelecteAll = false
        
        if mentionAll == nil {
            return 
        }
        
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
            self?.mentionAll?()
        }).disposed(by: disposeBag)
        
        let hStack = UIStackView(arrangedSubviews: [avatarView, nameLabel, UIView(), arrow])
        hStack.spacing = 8
        hStack.alignment = .center
        
        header.addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        contentStack.insertArrangedSubview(header, at: 0)
    }
}
