
import OUICore
import RxSwift

// 正在音视频会议的View
class InMeetingView : UIView {
    var isVideo: Bool = false
    var joinHandler: (() -> Void)?
    var members: [GroupMemberInfo] = [] {
        didSet {
            updateCount(count: members.count)
            userGridView.reloadData()
        }
    }
    
    func showIn(view: UIView) {
        if !view.subviews.contains(self) {
            view.addSubview(self)
            NSLayoutConstraint.activate([
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                self.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
            ])
        }
    }
    
    func dismiss() {
        if isExpanded {
            toggleExpand()
        }
        removeFromSuperview()
    }
    
    private let disposeBag = DisposeBag()
    private var isExpanded = false
    private let maxItemCount = 13 // 展示成员的最大数量
    
    lazy var countLabel: UILabel = {
        let v = UILabel()
        v.textColor = .c0089FF
        
        return v
    }()
    
    // 展开成员view
    lazy var expandArrow: UIImageView = {
        let v = UIImageView()
        v.image = .init(nameInBundle: "common_blue_arrow_up_icon")
        v.layer.transform = CATransform3DMakeRotation(Double.pi, 0, 0, 1)

        return v
    }()
    
    // 最小化view
    lazy var miniView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = true
        backgroundColor = .cB3D7FF
        
        let im = UIImageView()
        im.image = UIImage(nameInBundle: "common_mini_phone")
        im.contentMode = .center
        
        let infoSV = UIStackView.init(arrangedSubviews: [im, countLabel])
        infoSV.axis = .horizontal
        infoSV.spacing = 8
        infoSV.alignment = .center
        
        v.addSubview(infoSV)
        v.addSubview(expandArrow)
        
        im.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
        
        infoSV.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(8)
        }

        expandArrow.snp.makeConstraints { make in
            make.leading.equalTo(infoSV.snp.trailing)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(8)
            make.size.equalTo(16)
        }
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe(onNext: { [weak self] _ in
            guard let sself = self else { return }
            sself.toggleExpand()
        }).disposed(by: disposeBag)
        v.addGestureRecognizer(tap)
                
        return v
    }()
    
    lazy var userGridView: UICollectionView = {
        // 已经加入的用户
        let layout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 4
        layout.estimatedItemSize = .init(width: 40, height: 40)
        layout.itemSize = .init(width: 40, height: 40)
        
        let c = UICollectionView(frame: .zero, collectionViewLayout: layout)
        c.register(UICollectionViewCell.self,
                   forCellWithReuseIdentifier: "usersCell")
        
        c.delegate = self
        c.dataSource = self
        c.backgroundColor = .white
        
        return c
    }()
    
    // 成员view
    lazy var membersView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 5
        v.layer.masksToBounds = true
        // 加入按钮
        let b = UIButton(type: .system)
        b.setTitle("加入".innerLocalized(), for: .normal)
        b.setTitleColor(.c0089FF, for: .normal)
        b.backgroundColor = .white
        
        b.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let sself = self else { return }
            sself.toggleExpand()
            sself.joinHandler?()
        }).disposed(by: disposeBag)
        
        let separator = UIView()
        separator.backgroundColor = .lightGray
        
        let verSV = UIStackView.init(arrangedSubviews: [userGridView, separator, b])
        verSV.axis = .vertical
        verSV.spacing = 2
        v.addSubview(verSV)
        
        separator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        verSV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return v
    }()
    
    func updateCount(count: Int) {
        countLabel.text = "nPeopleCalling".innerLocalizedFormat(arguments: count)
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .cB3D7FF
        layer.cornerRadius = 5
        
        addSubview(membersView)
        addSubview(miniView)
        
        miniView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(40)
        }
        
        membersView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalToSuperview()
            make.top.equalTo(miniView.snp.bottom)
            make.height.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggleExpand() {
        self.isExpanded = !self.isExpanded

        membersView.snp.updateConstraints { make in
            if self.isExpanded {
                make.height.equalTo(self.userGridView.contentSize.height + 44)
                make.bottom.equalToSuperview().inset(8)
            } else {
                make.height.equalTo(0)
                make.bottom.equalToSuperview()
            }
        }
        
        expandArrow.layer.transform = !isExpanded ? CATransform3DMakeRotation(Double.pi, 0, 0, 1) : CATransform3DIdentity
    }
}

extension InMeetingView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count > maxItemCount ? maxItemCount + 1 : members.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "usersCell", for: indexPath)
        
        let member = members[indexPath.row]
        
        var faceURL = member.faceURL
        var nickName = member.nickname
        
        if indexPath.row == maxItemCount {
            faceURL = nil
            nickName = "..."
        }
        
        let avatar = AvatarView()
        avatar.setAvatar(url: faceURL, text: nickName, onTap: nil)
        
        cell.contentView.addSubview(avatar)
        
        avatar.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalTo(42)
        }
        
        return cell
    }
}

extension InMeetingView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.numberOfItems(inSection: section) == 1 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

            return UIEdgeInsets(top: 8, left: 8, bottom: 0, right: collectionView.frame.width - flowLayout.itemSize.width - 8)
        }

        return UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 8)
    }
}
