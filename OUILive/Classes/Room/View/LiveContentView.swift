
import Foundation
import RxSwift
import SnapKit
import LiveKitClient

enum LiveContentViewAction {
    case camera
    case cell(index: Int)
    case doubleTap(index: Int)
    case content
}

private class CustomFlowLayout: UICollectionViewFlowLayout {

    // 保存所有item的attributes
    private var attributesArr: [UICollectionViewLayoutAttributes] = []

    private var numberOfSectoins = 0
    private var numberOfItemsInSection = 0

    init(numberOfSectoins: Int = 0, numberOfItemsInSection: Int = 0) {
        super.init()
        self.numberOfSectoins = numberOfSectoins
        self.numberOfItemsInSection = numberOfItemsInSection
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK:- 重新布局
    override func prepare() {
        super.prepare()
        
        guard let collectionView else { return }
        attributesArr.removeAll()
        
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
        
        guard collectionView.numberOfSections >= 1 else { return }
        
        var attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: 0, section: 0))
        attributes.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
        attributesArr.append(attributes)
        
        let itemsCount = collectionView.numberOfItems(inSection: 1)
        for itemIndex in 0..<itemsCount {
            var attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: itemIndex, section: 1))
            
            let itemWidth = collectionView.bounds.width / CGFloat(numberOfItemsInSection)
            let itemHeight = collectionView.bounds.height / CGFloat(numberOfSectoins)
                            
            let row = itemIndex / numberOfItemsInSection
            let column = itemIndex % numberOfItemsInSection
            
            let y = CGFloat(row) * itemHeight
            let x = CGFloat(column) * itemWidth + collectionView.bounds.width
            
            attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemHeight)
            attributesArr.append(attributes)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView else { return .zero }
        
        let totalItems = collectionView.numberOfItems(inSection: 1) //除去大屏
        let itemsPerPage = numberOfSectoins * numberOfItemsInSection
        let totalPages = (totalItems + itemsPerPage - 1) / itemsPerPage
                
        let contentWidth = CGFloat(totalPages + 1) * collectionView.bounds.width
        
        return CGSize(width: contentWidth, height: collectionView.bounds.height)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        attributesArr
    }
}

class LiveContentView: UIView {
    
    let numberOfSectoins = 2
    let numberOfItemsInSection = 2
    
    // 获取所有的房间成员
    var onTap: ((_ action: LiveContentViewAction) -> Void)?
    var numberOfItems: (() -> Int)!
    var itemSize: (() -> CGSize)?
    var participantHandler: ((_ index: Int) -> (Participant?, Bool, Bool)?)! // 第一个参数：成员信息，第二个：展示是否是自己, the third: is host
    
    var hosterName: (() -> String?)?
    let disposeBag = DisposeBag()
    var leadingParticipantHandler: (() -> (Participant?, Bool, Bool)?)! // The big screen member in the first position
    
    lazy var collectionView: UICollectionView = {
        print("creating UICollectionView...")
        let layout = CustomFlowLayout(numberOfSectoins: numberOfSectoins, numberOfItemsInSection: numberOfItemsInSection)
        
        let r = UICollectionView(frame: .zero, collectionViewLayout: layout)
        r.register(LiveParticipantVideoCell.self, forCellWithReuseIdentifier: NSStringFromClass(LiveParticipantVideoCell.self))
        r.delegate = self
        r.dataSource = self
        r.contentInsetAdjustmentBehavior = .never
        r.isPagingEnabled = true
        r.backgroundColor = .clear
        r.isPagingEnabled = true
        r.showsHorizontalScrollIndicator = false
        r.showsVerticalScrollIndicator = true
        r.contentInset = .zero
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        r.addGestureRecognizer(tap)
        
        return r
    }()
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        onTap?(.content)
    }
    
    lazy var pageControl: UIPageControl = {
        let v = UIPageControl()
        v.currentPageIndicatorTintColor = .white
        v.pageIndicatorTintColor = .lightGray
        
        return v
    }()
    
    private let signalParticipantVedioView: LiveParticipantVideoCell = {
        let v = LiveParticipantVideoCell()
        v.isUserInteractionEnabled = true
        v.isHidden = true
        v.frame = CGRectMake(CGRectGetWidth(UIScreen.main.bounds) - (90 + 20), 100, 90, 160)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        v.addGestureRecognizer(panGesture)
        
        return v
    }()
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        // 移动状态
        let moveState = gesture.state
        switch moveState {
        case .changed:
            // 移动过程中,获取移动轨迹,重置center坐标点
            let point = gesture.translation(in: signalParticipantVedioView.superview)
            signalParticipantVedioView.center = CGPoint(x: signalParticipantVedioView.center.x + point.x, y: signalParticipantVedioView.center.y + point.y)
            break
        case .ended:
            // 移动结束后,相关逻辑处理,重置center坐标点
            let point = gesture.translation(in: signalParticipantVedioView.superview)
            let newPoint = CGPoint(x: signalParticipantVedioView.center.x + point.x, y: signalParticipantVedioView.center.y + point.y)
            
            // 自动吸边动画
            UIView.animate(withDuration: 0.1) { [self] in
                signalParticipantVedioView.center = self.resetPosition(point: newPoint)
            }
            break
        default: break
        }
        // 重置 panGesture
        gesture.setTranslation(.zero, in: signalParticipantVedioView.superview!)
    }
    
    private func resetPosition(point: CGPoint) -> CGPoint {
        var newPoint = point
        let limitMargin = 20.0
        let bottomMargin = CGRectGetMaxY(signalParticipantVedioView.superview!.frame) - 200
        // 靠左吸边
        if point.x <= (CGRectGetWidth(signalParticipantVedioView.superview!.frame) / 2) {
            newPoint.x = (CGRectGetWidth(signalParticipantVedioView.frame) / 2.0) + limitMargin
        } else {
            newPoint.x = CGRectGetWidth(signalParticipantVedioView.superview!.frame) - (CGRectGetWidth(signalParticipantVedioView.frame) / 2) - limitMargin
        }
        
        // 靠上
        if point.y <= 100 {
            newPoint.y = 100
        } else if point.y > bottomMargin {
            newPoint.y = bottomMargin
        }
        
        return newPoint
    }
    
    private var cellReference = NSHashTable<LiveParticipantVideoCell>.weakObjects()
    private var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.reComputeVideoViewEnabled()
        })
        
        backgroundColor = UIColor(red: 34 / 255.0, green: 34 / 255.0, blue: 34 / 255.0, alpha: 1)
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        addSubview(signalParticipantVedioView)
        
        addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.bottom.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
    }
      
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    func reloadParticipants() {
        DispatchQueue.main.async { [self] in
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates { [weak self] in
                    self?.collectionView.reloadSections([1], animationStyle: .none)
                }
//            if numberOfItems() == 2 { // 小于两人的时候类似音视频聊天
//                if let participant = participantHandler(1) {
//                    signalParticipantVedioView.isHidden = false
//                    signalParticipantVedioView.participant = participant.0
//                    signalParticipantVedioView.toggleCameraButton.isHidden = !participant.1
//                }
//            } else {
                signalParticipantVedioView.isHidden = true
//            }
            }
        }
    }
    
    func reloadLeadingParticipants() {
        DispatchQueue.main.async { [self] in
            UIView.performWithoutAnimation { [self] in
                collectionView.performBatchUpdates { [weak self] in
                    self?.collectionView.reloadSections([0], animationStyle: .none)
                }
            }
        }
    }
}

extension LiveContentView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.bounds.size

        if indexPath.section == 0 {
            return size
        }

        let numberOfItemsPerRow: CGFloat = CGFloat(numberOfItemsInSection)
        let spacingBetweenItems: CGFloat = 0

        let totalSpacing = (numberOfItemsPerRow - 1) * spacingBetweenItems
        let availableWidth = collectionView.bounds.width - totalSpacing

        let itemWidth = availableWidth / numberOfItemsPerRow
        let itemHeight = (collectionView.bounds.height - totalSpacing) / numberOfItemsPerRow

        size = CGSize(width: itemWidth, height: itemHeight)

        return itemSize?() ?? size
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("didSelectItemAt: \(indexPath)")
//        onTap?(.cell(index: indexPath.item))
//    }
    
    func reComputeVideoViewEnabled() {
        let visibleCells = collectionView.visibleCells.compactMap { $0 as? LiveParticipantVideoCell }
        let offScreenCells = cellReference.allObjects.filter { !visibleCells.contains($0) }
        
        for cell in visibleCells.filter({ !$0.videoView.isEnabled }) {
            print("setting cell#\(cell.cellId) to true")
            cell.videoView.isEnabled = true
        }
        
        for cell in offScreenCells.filter({ $0.videoView.isEnabled }) {
            print("setting cell#\(cell.cellId) to false")
            cell.videoView.isEnabled = false
        }
    }
}

extension LiveContentView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let totalItems = numberOfItems()
        let itemsPerPage = numberOfSectoins * numberOfItemsInSection
        let totalPages = (totalItems + itemsPerPage - 1) / itemsPerPage
        
        pageControl.numberOfPages = totalItems == 1 ? 2 : totalPages + 1
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
        let totalItems = numberOfItems()
        
        return totalItems
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(LiveParticipantVideoCell.self),
                                                      for: indexPath) as! LiveParticipantVideoCell
        
        var participant: (Participant?, Bool, Bool)?
        
        if indexPath.section == 0 {
            participant = leadingParticipantHandler?()
            cell.onDoubleTap = nil
            
            if let pinchGestureRecognizer = cell.scrollView.pinchGestureRecognizer {
                collectionView.addGestureRecognizer(pinchGestureRecognizer)
            }
            
            collectionView.addGestureRecognizer(cell.scrollView.panGestureRecognizer)
        } else {
            participant = participantHandler(indexPath.item)
            
            cell.onDoubleTap = { [weak self] in
                guard let self else { return }
                
                onTap?(.doubleTap(index: indexPath.item))
            }
        }
        
        if let participant = participant {
            let p = participant.0
            let isSelf = participant.1
            let isHost = participant.2
            
            cellReference.add(cell)
            cell.participant = p
            cell.toggleCameraButton.isHidden = !isSelf
            cell.infoView.hosterImageView.isHidden = !isHost
            
            cell.onTap = { [weak self] action in
                guard let self else { return }
                
                switch action {
                case .camera:
                    onTap?(.camera)
                case .tap:
                    onTap?(.cell(index: indexPath.item))
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? LiveParticipantVideoCell else { return }
        
        if let pinchGestureRecognizer = cell.scrollView.pinchGestureRecognizer {
            collectionView.addGestureRecognizer(pinchGestureRecognizer)
        }
    
        collectionView.addGestureRecognizer(cell.scrollView.panGestureRecognizer)
        
        cell.scrollView.setZoomScale(1.0, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.frame.width
        let currentPage = Int((collectionView.contentOffset.x + pageWidth / 2) / pageWidth)

        pageControl.currentPage = currentPage
    }
}
