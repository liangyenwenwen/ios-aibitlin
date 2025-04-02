import InputBarAccessoryView
import OUICore

// MARK: - 张亚飞打的标记  聊天底部菜单栏 选择
public struct PadItemModel: Hashable {
    var padItemType: PadItemType
    var name: String?
    var icon: String?
    var iconUrl:String?
//    var data:Any?
}
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
    case customer
}

public protocol InputPadViewDelegate: AnyObject {
    func didSelect(padItemModel: PadItemModel)
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
    private let items:[PadItemModel] = [PadItemModel(padItemType:.camera,name: "相机".localized(),icon:"inputbar_pad_camera_icon", iconUrl: ""),
                                        PadItemModel(padItemType:.album,name: "照片".localized(),icon:"inputbar_pad_photo_icon", iconUrl: ""),
                                        PadItemModel(padItemType:.videoCall,name: "视频通话".localized(),icon:"inputbar_pad_video_icon", iconUrl: ""),
                                        PadItemModel(padItemType:.voiceCall,name: "语音通话".localized(),icon:"inputbar_pad_voice_icon", iconUrl: ""),
                                        PadItemModel(padItemType:.card,name: "名片".localized(),icon:"inputbar_pad_card_icon", iconUrl: ""),
                                        PadItemModel(padItemType:.boke,name: "网站".localized(),icon:"inputbar_pad_boke_icon", iconUrl: ""),
                                        PadItemModel(padItemType:.file,name: "文件".localized(),icon:"inputbar_pad_file_icon", iconUrl: "")]
    
    private lazy var collectionView: UICollectionView = {
        let v = UICollectionView(frame: CGRect.zero, collectionViewLayout: ChatHorizontalLayout(column: 4, row: 2))
        v.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.className)
        v.backgroundColor = .clear
        v.dataSource = self
        v.delegate = self
        
        return v
    }()
    lazy var pageControl: UIPageControl = { [unowned self] in
        let pageC = UIPageControl()
        pageC.numberOfPages = items.count / 8 + (items.count % 8 == 0 ? 0 : 1)
        pageC.currentPage = 0
        pageC.pageIndicatorTintColor = UIColor.lightGray
        pageC.currentPageIndicatorTintColor = UIColor.gray
        pageC.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        return pageC
    }()
    @objc func pageControlValueChanged(_ sender: UIPageControl) {
            let currentPage = sender.currentPage
            print("当前选中的页面是: \(currentPage)")
            // 这里可以添加更多逻辑，比如切换页面内容等
        var frame = collectionView.frame
                frame.origin.x = frame.size.width * CGFloat(sender.currentPage)
                frame.origin.y = 0
                //展现当前页面内容
        collectionView.scrollRectToVisible(frame, animated:true)
        }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .init(hexString: "#EFF2F6")
        translatesAutoresizingMaskIntoConstraints = false
        layoutMargins = .zero
        
        self.addSubview(collectionView)
        self.addSubview(pageControl)
        
        collectionView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(self)
            make.height.equalTo(220)
        }
        
        pageControl.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.height.equalTo(25)
            make.top.equalTo(collectionView.snp_bottom)
        }
        collectionView.contentSize = CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height)
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
        v.textAlignment = .center
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        imageView.snp_makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
        }
        titleLabel.snp_makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(imageView.snp_bottom).offset(8)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InputPadView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.className, for: indexPath) as! ItemCell
        
        let model = items[indexPath.row]
        if model.padItemType == .customer{
            cell.imageView.setImageWithURLString(model.iconUrl, placeholder: nil)
        }else{
            cell.imageView.image = UIImage(named: model.icon ?? "")
        }
        cell.titleLabel.text = model.name
        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = items[indexPath.row]
        delegate?.didSelect(padItemModel: model)
    }
}
extension InputPadView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.x
        let page = contentOffset / scrollView.frame.size.width + (Int(contentOffset) % Int(scrollView.frame.size.width) == 0 ? 0 : 1)
        if pageControl.currentPage != Int(page) {
            pageControl.currentPage = Int(page)
        }
    }
}
