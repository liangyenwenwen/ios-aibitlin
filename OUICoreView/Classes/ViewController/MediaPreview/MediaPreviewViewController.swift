
import Lantern
import AVKit
import Kingfisher
import ProgressHUD
import OUICore

public enum PreviewMediaType {
    case image
    case video
    case gif
}

public struct MediaResource {
    public let thumbUrl: URL?
    public let url: URL
    public let type: PreviewMediaType
    public let ID: String?
    
    public init(thumbUrl: URL? = nil, url: URL, type: PreviewMediaType = .image, ID: String? = nil) {
        self.thumbUrl = thumbUrl
        self.url = url
        self.type = type
        self.ID = ID
    }
}

public class MediaPreviewViewController: UIViewController {
    
    private let lantern: Lantern = {
        let v = Lantern()
        
        return v
    }()
    
    public var onDelete: ((Int) -> Void)?
    public var onDismiss: (() -> Void)?
    public var onButtonAction: ((PreviewModalView.ActionType) -> Void)?
    
    private var showIndicator = false
    private let modalView = PreviewModalView()
    
    public init(resources: [MediaResource], index: Int = 0, showIndicator: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.dataSource = resources
        self.showIndicator = showIndicator
        self.currentIndex = index
    }
    
    public func showIn(controller: UIViewController, senders: [UIView] = []) {
        hidesBottomBarWhenPushed = true
        modalPresentationStyle = .overCurrentContext
        
        if !senders.isEmpty {
            lantern.transitionAnimator = LanternZoomAnimator(previousView: { index -> UIView? in
                return senders[index]
            })
        }
        
        controller.present(self, animated: true)
    }
    
    public func showIn(controller: UIViewController, sender: ((_ index: Int) -> UIView?)? = nil) {
        hidesBottomBarWhenPushed = true
        modalPresentationStyle = .overCurrentContext
        
        if let sender {
            lantern.transitionAnimator = LanternZoomAnimator(previousView: { index -> UIView? in
                sender(index)
            })
        }
        
        controller.present(self, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var dataSource: [MediaResource]!
    private var currentIndex = 0

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupBrowers()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lantern.setStatusBar(hidden: true)
    }

    private func setupBrowers() {
        lantern.pageIndex = currentIndex
        
        if showIndicator {
            let indicator = PageIndicator()
            lantern.pageIndicator = indicator
            
            if onDelete != nil {
                indicator.deleteButton.isHidden = false
                indicator.onDelete = { [weak self, weak lantern] index in
                    guard let self, let lantern else { return }
                    dataSource.remove(at: index)
                    onDelete!(index)
                    lantern.reloadData()
                }
            }
        }
        
        lantern.numberOfItems = { [weak self] in
            self?.dataSource.count ?? 0
        }
        lantern.cellClassAtIndex = { [weak self] index in
            guard let self else { return ImageZoomCell.self }
            let resource = self.dataSource[index]
            return resource.type == .video ? VideoZoomCell.self : ImageZoomCell.self
        }
        lantern.reloadCellAtIndex = { [weak self] context in
            guard let resource = self?.dataSource[context.index] else { return }
            if resource.type == .video {
                let lanternCell = context.cell as? VideoZoomCell
                lanternCell?.setInfo(thumbPath: resource.thumbUrl?.relativeString, videoURL: resource.url, autoPlay: context.index == self?.currentIndex)
                
                lanternCell?.frameChangedHandler = { [weak self] frame in
                    self?.view.frame = frame
                }
                lanternCell?.dismissHandler = { [weak self] in
                    self?.dismissView()
                }
                lanternCell?.longPressedHandler = { [weak self, weak lanternCell] in
                    guard let self else { return }
                    modalView.show()
                    modalView.onButtonAction = { type in
                        switch type {
                        case .save:
                            PhotoHelper().saveVideoToAlbum(path: resource.url.absoluteString)
                        case .forward:
                            self.onDismiss?()
                            self.dismiss(animated: false) {
                                self.onButtonAction?(type)
                            }
                        }
                    }
                }
            } else {
                let lanternCell = context.cell as? ImageZoomCell
                if let thumb = resource.thumbUrl?.absoluteString {
                    
                    lanternCell?.imageView.setImage(with: thumb) { [weak lanternCell] image in
                        lanternCell?.imageView.image = image
                        lanternCell?.imageView.setImage(with: resource.url.relativeString, placeholderImage: image, showIndicator: true)
                    }
                }
                
                lanternCell?.frameChangedHandler = { [weak self] frame in
                    self?.view.frame = frame
                }
                lanternCell?.dismissHandler = { [weak self] in
                    self?.dismissView()
                }
                lanternCell?.longPressedAction = { [weak self, weak lanternCell] (cell, state) in
                    guard let self, let image = cell.imageView.image else { return }
                    modalView.show()
                    modalView.onButtonAction = { type in
                        switch type {
                        case .save:
                            PhotoHelper().saveImageToAlbum(image: image)
                        case .forward:
                            self.onDismiss?()
                            self.dismiss(animated: false) {
                                self.onButtonAction?(type)
                            }
                        }
                    }
                }
            }
        }
        lantern.cellDidAppear = { [weak self] cell, index in
            self?.currentIndex = index
        }
        
        lantern.show()
    }
    
    private func dismissView() {
        onDismiss?()
        dismiss(animated: false)
    }
    
    deinit {
        print("media preview deinit")
    }
}
