import InputBarAccessoryView
import OUICore

// MARK: - 张亚飞打的标记  聊天底部菜单栏 选择
public enum PadItemType: CaseIterable {
    case album
    case camera
    case media
    case file
    case card
    case location
    case boke
    case videoCall
    case voiceCall

    var name: String {
        switch self {
        case .album:
            return "照片".localized()
        case .camera:
            return "相机".localized()
        case .card:
            return "名片".localized()
        case .media:
            return "音视频".innerLocalized()
        case .location:
            return "定位".innerLocalized()
        case .file:
            return "文件".localized()
        case .boke:
            return "博客".localized()
        case .voiceCall:
            return "语音通话".localized()
        case .videoCall:
            return "视频通话".localized()
        }
    }

    var image: UIImage? {
        let imageName: String
        switch self {
        case .album:
            imageName = "inputbar_pad_photo_icon"
        case .camera:
            imageName = "inputbar_pad_camera_icon"
        case .card:
            imageName = "inputbar_pad_card_icon"
        case .media:
            imageName = "inputbar_pad_voip_icon"
            return UIImage(nameInBundle: imageName)
        case .location:
            imageName = "inputbar_pad_location_icon"
        case .file:
            imageName = "inputbar_pad_file_icon"
        case .boke:
            imageName = "inputbar_pad_boke_icon"
        case .videoCall:
            imageName = "inputbar_pad_video_icon"
        case .voiceCall:
            imageName = "inputbar_pad_voice_icon"
            
        }
        return UIImage(named: imageName)
//        return UIImage(nameInBundle: imageName)
    }
}

public protocol InputPadViewDelegate: AnyObject {
    func didSelect(type: PadItemType)
}

// MARK: - 张亚飞打的标记  底部弹窗
class InputPadView: UIView {

    private var size: CGSize? = CGSize(width: UIScreen.main.bounds.width, height: 254) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        size ?? super.intrinsicContentSize
    }
    
    public weak var delegate: InputPadViewDelegate?
    
    // 每行要展示的 item 数量
    private let itemsPerRow = 4
    // MARK: - 张亚飞打的标记  第一步修改下方按钮  聊天功能下面展示内容
//    private let items: [PadItemType] = PadItemType.allCases
    private let items: [PadItemType] = [.camera, .album, .videoCall, .voiceCall, .card, .boke, .file]
    
    private lazy var collectionView: UICollectionView = {
        
        var layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 10.0
        
//        layout.itemSize = CGSize(width: (intrinsicContentSize.width - layout.minimumInteritemSpacing * 3) / CGFloat(itemsPerRow), height: (intrinsicContentSize.height - layout.minimumLineSpacing) / 2.0)
        layout.itemSize = CGSize(width: ((intrinsicContentSize.width - 40) - layout.minimumInteritemSpacing * 3) / CGFloat(itemsPerRow), height: (220  - layout.minimumLineSpacing) / 2.0)
        
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.className)
        v.backgroundColor = .clear
        v.isScrollEnabled = false
        v.dataSource = self
        v.delegate = self
        
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .secondarySystemBackground
        backgroundColor = .init(hexString: "#EFF2F6")
        translatesAutoresizingMaskIntoConstraints = false
        layoutMargins = .zero
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
//            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -34),
        ])
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class ItemCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        return v
    }()

    let titleLabel: UILabel = {
        let v = UILabel()
        v.font = .f12
        v.textColor = .c0C1C33
        
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let vStack: UIStackView = {
            let v = UIStackView(arrangedSubviews: [imageView, titleLabel])
            v.axis = .vertical
            v.alignment = .center
            v.spacing = 8
            
            return v
        }()
        
        contentView.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -0)
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InputPadView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
    
        let count = items.count
        
        return count % itemsPerRow == 0 ? count / itemsPerRow : count / itemsPerRow + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        let count = items.count - section * itemsPerRow

        return count / itemsPerRow == 0 ? count % itemsPerRow : itemsPerRow
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.className, for: indexPath) as! ItemCell
        
        let index = indexPath.section * itemsPerRow + indexPath.row
        let item = items[index]

        print(item.name)
        cell.imageView.image = item.image
        cell.titleLabel.text = item.name
        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.section * itemsPerRow + indexPath.row
        let item = items[index]
        delegate?.didSelect(type: item)
    }
}
