
import Foundation
import SnapKit
import RxCocoa
import RxSwift

fileprivate let metaSize = 100.0
fileprivate let maxLength = 500
fileprivate let labelTextColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)

// 输入框
class PublishInputTextCell: UITableViewCell, UITextViewDelegate {
    
    private lazy var textView: MomentTextView = {
        let v = MomentTextView()
        v.font = .f17
        v.textColor = labelTextColor
        v.maxCount = maxLength
        v.onKeyAction = { [weak self] (action: TextAction)  in
            switch action {
            case .change(let text):
                self?.updateLimitNumber(text)
                self?.onChange?(text.trimmingCharacters(in: .whitespacesAndNewlines))
            case .delete:
                break
            case .done:
                break
            case .keyboard(let rect, let duration):
                break
            }
        }
        v.snp.makeConstraints { make in
            make.height.equalTo(150)
        }
        return v
    }()
    
    public lazy var limitText: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 14)
        v.text = "0/\(maxLength)"
        v.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        return v
    }()
    
    private func updateLimitNumber(_ text: String) {
        limitText.text = "\(text.trimmingCharacters(in: .whitespacesAndNewlines).length) / \(maxLength)"
    }
    // 编辑完成
    var onChange:((_ text: String?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .none
        selectionStyle = .none
        
        let verSV = UIStackView(arrangedSubviews: [textView, limitText])
        verSV.axis = .vertical
        verSV.alignment = .trailing
        verSV.distribution = .equalSpacing
        contentView.addSubview(verSV)
        
        textView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        verSV.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PublishInputMetaCell: UITableViewCell {
    
    lazy var metasCollectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        //定义每个UICollectionView 横向的间距
        flowLayout.minimumLineSpacing = 5;
        //定义每个UICollectionView 纵向的间距
        flowLayout.minimumInteritemSpacing = 5;
        //定义每个UICollectionView 的边距距
        flowLayout.estimatedItemSize = .init(width: UIScreen.main.bounds.width - 30, height: 150)
        flowLayout.itemSize = UICollectionViewFlowLayout.automaticSize
        let v = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        v.register(MetaCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(MetaCollectionViewCell.self))
        v.delegate = self
        v.dataSource = self
        v.backgroundColor = .clear
        
        v.collectionViewLayout.perform(Selector.init(("_setRowAlignmentsOptions:")),with:NSDictionary.init(dictionary:["UIFlowLayoutCommonRowHorizontalAlignmentKey":NSNumber.init(value:NSTextAlignment.left.rawValue)]));
        
        return v
    }()
    
    var numberOfItems: (() -> Int)!
    var imagePathAtIndexPath: ((_ index: Int) -> String?)!
    var showAddButton: (() -> Bool)?
    var addViewOnItem: ((_ index: Int) -> UIView?)?
    var onTap: ((_ index: Int) -> Void)?
    
    func reloadData() {
        metasCollectionView.reloadData()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .none
        selectionStyle = .none
        
        contentView.addSubview(metasCollectionView)
        metasCollectionView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        metasCollectionView.layoutIfNeeded()
        let heigth = self.metasCollectionView.collectionViewLayout.collectionViewContentSize.height;
        return CGSizeMake(size.width, heigth);
    }
    
}

extension PublishInputMetaCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems() + (showAddButton?() == true ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: NSStringFromClass(MetaCollectionViewCell.self), for: indexPath) as! MetaCollectionViewCell
        
        if showAddButton?() == true, indexPath.item == numberOfItems() {
            cell.imageView.image = UIImage(nameInBundle:"momnets_meta_add_icon")
        }
        
        if let view = addViewOnItem?(indexPath.item) {
            cell.imageView.addSubview(view)
            view.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        } else {
            cell.imageView.subviews.first?.removeFromSuperview()
        }
        
        if let path = imagePathAtIndexPath(indexPath.item) {
            let url = URL.init(fileURLWithPath: path)
            let data = try! Data.init(contentsOf: url)
            cell.imageView.image = .init(data: data)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTap?(indexPath.item)
    }
}

class MetaCollectionViewCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let v = UIImageView()
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 6
        
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
            make.size.equalTo(metaSize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}

// 空白
class PublishSpaceCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .none
        selectionStyle = .none
        if #available(iOS 13.0, *) {
            contentView.backgroundColor = .systemGray6
        } else {
            contentView.backgroundColor = .systemGray
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// 点击选择,尾部有值
class PublishValueCell: UITableViewCell {
    
    lazy var iconImageView: UIImageView = {
        let v = UIImageView()
        v.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        return v
    }()
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textColor = labelTextColor
        v.font = .systemFont(ofSize: 14)
        return v
    }()
    
    lazy var trailingLabel: UILabel = {
        let v = UILabel()
        v.textColor = labelTextColor
        v.font = .systemFont(ofSize: 14)
        return v
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        
        let horSV = UIStackView(arrangedSubviews: [iconImageView, titleLabel, trailingLabel])
        horSV.alignment = .center
        horSV.spacing = 8
        contentView.addSubview(horSV)
        
        trailingLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        horSV.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
