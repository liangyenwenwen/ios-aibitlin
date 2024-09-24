
import UIKit
import Foundation
import OUICore
import AVFoundation
import Lantern
import ZFPlayer

class VideoZoomCell: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate, LanternCell, LanternZoomSupportedCell {
    
    /// 弱引用PhotoBrowser
    weak var lantern: Lantern?
    
    var frameChangedHandler: ((CGRect) -> Void)?
    var dismissHandler: (() -> Void)?
    var singleTapHandler: (() -> Void)?
    var longPressedHandler: (() -> Void)?
    
    func setInfo(thumbPath: String?, videoURL: URL?, autoPlay: Bool = false) {
        if let videoURL, playerManager.assetURL != videoURL {
            print("\(#function): video URL \(videoURL)")
            let filePath = FileHelper.shared.exsit(path: videoURL.absoluteString)
            let result = filePath != nil ? URL(fileURLWithPath: filePath!) : videoURL
            
            playerManager.assetURL = result
            controlView.showTitle("", coverURLString: thumbPath, fullScreenMode: .portrait)
            playerManager.shouldAutoPlay = autoPlay
            controlView.resetControlView()
            
            saveToLocal()
        } else {
            playerManager.assetURL = nil
        }
    }

    var index: Int = 0
    
    private lazy var contentView: UIView = {
        let v = UIView()
        v.frame = bounds
        
        return v
    }()
    
    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.maximumZoomScale = 2.0
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        v.contentInsetAdjustmentBehavior = .never
        v.delaysContentTouches = false
        v.frame = bounds
        
        return v
    }()
    
    private var player: ZFPlayerController!
    
    private lazy var playerManager: ZFAVPlayerManager = ZFAVPlayerManager()
    
    private lazy var controlView: ZFPlayerControlView = {
        let v = ZFPlayerControlView()
        v.fastViewAnimated = true
        v.effectViewShow = false
        v.prepareShowLoading = true
        v.showCustomStatusBar = true
        v.customDisablePanMovingDirection = true
        v.prepareShowLoading = true
        v.prepareShowControlView = true
        
        return v
    }()
    
    private lazy var closeButton: UIButton = {
        let v = UIButton(type: .system)
        v.setImage(UIImage(systemName: "xmark"), for: .normal)
        v.tintColor = .white
        v.translatesAutoresizingMaskIntoConstraints = false
        v.addTarget(self, action: #selector(handleCloseAction(_:)), for: .touchUpInside)
        
        return v
    }()
    
    @objc
    private func handleCloseAction(_ sender: UIButton) {
        lantern?.dismiss()
        dismissHandler?()
    }
    
    deinit {
        LanternLog.high("deinit - \(self.classForCoder)")
    }
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    /// 生成实例
    public static func generate(with lantern: Lantern) -> Self {
        let cell = Self.init(frame: .zero)
        cell.lantern = lantern
        return cell
    }
    
    private func setup() {
        backgroundColor = .clear
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 100.h),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
        ])
        
        player = ZFPlayerController(playerManager: playerManager, containerView: contentView)
        player.controlView = controlView
        player.disableGestureTypes = .pan
        player.disablePanMovingDirection = .horizontal
        
        controlView.backBtnClickCallback = { [weak self] in
            self?.player.stop()
        }
        
        /// 拖动手势
        addPanGesture()
        // 单击手势
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap(_:)))
        addGestureRecognizer(singleTap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPress)
    }
    
    private func saveToLocal() {
        guard let videoURL = playerManager.assetURL else { return }
        let name = videoURL.relativeString.md5 + "." + videoURL.relativeString.split(separator: ".").last!
        guard FileHelper.shared.exsit(path: videoURL.relativeString, name: name) == nil else { return }
        
        let task = URLSession.shared.downloadTask(with: URLRequest(url: videoURL)) { [weak self] tempURL, response, error in
            guard let self, let tempURL else { return }
            
            FileHelper.shared.saveVideo(from: tempURL.path, name: name)
        }
        task.resume()
    }
    
    private weak var existedPan: UIPanGestureRecognizer?
    
    /// 添加拖动手势
    private func addPanGesture() {
        guard existedPan == nil else {
            return
        }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        // 必须加在图片容器上，否则长图下拉不能触发
        scrollView.addGestureRecognizer(pan)
        existedPan = pan
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        contentView.frame = bounds
        scrollView.setZoomScale(1.0, animated: false)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        contentView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        contentView.center = computeContentLayoutCenter(in: scrollView)
    }
    
    func computeImageLayoutSize(for image: UIImage?, in scrollView: UIScrollView) -> CGSize {
        guard let imageSize = image?.size, imageSize.width > 0 && imageSize.height > 0 else {
            return .zero
        }
        var width: CGFloat
        var height: CGFloat
        let containerSize = scrollView.bounds.size
        if containerSize.width < containerSize.height {
            width = containerSize.width
            height = imageSize.height / imageSize.width * width
        } else {
            height = containerSize.height
            width = imageSize.width / imageSize.height * height
            if width > containerSize.width {
                width = containerSize.width
                height = imageSize.height / imageSize.width * width
            }
        }
        
        return CGSize(width: width, height: height)
    }
    
    func computeContentLayoutCenter(in scrollView: UIScrollView) -> CGPoint {
        var x = scrollView.contentSize.width * 0.5
        var y = scrollView.contentSize.height * 0.5
        let offsetX = (bounds.width - scrollView.contentSize.width) * 0.5
        if offsetX > 0 {
            x += offsetX
        }
        let offsetY = (bounds.height - scrollView.contentSize.height) * 0.5
        if offsetY > 0 {
            y += offsetY
        }
        return CGPoint(x: x, y: y)
    }
    
    @objc
    private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            longPressedHandler?()
        }
    }
    
    /// 单击
    @objc open func onSingleTap(_ tap: UITapGestureRecognizer) {
//        lantern?.dismiss()
//        dismissHandler?()
    }
    
    private func hideWidgets(hidden: Bool = true) {
        UIView.animate(withDuration: 0.2) { [self] in
            closeButton.alpha = hidden ? 0.0 : 1.0
            lantern?.pageIndicator?.isHidden = hidden
        }
    }

    /// 记录pan手势开始时imageView的位置
    private var beganFrame = CGRect.zero
    
    /// 记录pan手势开始时，手势位置
    private var beganTouch = CGPoint.zero
    
    /// 响应拖动
    @objc open func onPan(_ pan: UIPanGestureRecognizer) {

        switch pan.state {
        case .began:
            beganFrame = contentView.frame
            beganTouch = pan.location(in: scrollView)
        case .changed:
            let result = panResult(pan)
            contentView.frame = result.frame
            frameChangedHandler?(result.frame)
            
            lantern?.maskView.alpha = result.scale * result.scale
            lantern?.setStatusBar(hidden: result.scale > 0.99)
            hideWidgets(hidden: result.scale < 0.99)
            
            
        case .ended, .cancelled:
            contentView.frame = panResult(pan).frame
            frameChangedHandler?(panResult(pan).frame)
            hideWidgets()
            lantern?.dismiss()
            dismissHandler?()
        default:
            break
        }
    }
    
    /// 计算拖动时图片应调整的frame和scale值
    private func panResult(_ pan: UIPanGestureRecognizer) -> (frame: CGRect, scale: CGFloat) {
        // 拖动偏移量
        let translation = pan.translation(in: scrollView)
        let currentTouch = pan.location(in: scrollView)
        
        // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - translation.y / bounds.height))
        
        let width = beganFrame.size.width * scale
        let height = beganFrame.size.height * scale
        
        // 计算x和y。保持手指在图片上的相对位置不变。
        // 即如果手势开始时，手指在图片X轴三分之一处，那么在移动图片时，保持手指始终位于图片X轴的三分之一处
        let xRate = (beganTouch.x - beganFrame.origin.x) / beganFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = currentTouch.x - currentTouchDeltaX
        
        let yRate = (beganTouch.y - beganFrame.origin.y) / beganFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = currentTouch.y - currentTouchDeltaY
        
        return (CGRect(x: x.isNaN ? 0 : x, y: y.isNaN ? 0 : y, width: width, height: height), scale)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 只处理pan手势
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = pan.velocity(in: self)
        // 向上滑动时，不响应手势
        if velocity.y < 0 {
            return false
        }
        // 横向滑动时，不响应pan手势
        if abs(Int(velocity.x)) > Int(velocity.y) {
            return false
        }
        // 向下滑动，如果图片顶部超出可视区域，不响应手势
        if scrollView.contentOffset.y > 0 {
            return false
        }
        // 响应允许范围内的下滑手势
        return true
    }
    
    var showContentView: UIView {
        return contentView
    }
}
