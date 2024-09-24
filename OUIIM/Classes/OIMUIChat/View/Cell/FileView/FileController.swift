
import Foundation
import OUICore

enum FileDownloadStatus {
    case normal
    case downloading
    case paused
    case completion
}

final class FileController: NSObject {
    
    var image = UIImage(nameInBundle: "chat_msg_file_zip_disable_icon") // 未下载完成的图
    var highlightedImage = UIImage(nameInBundle: "chat_msg_file_zip_normal_icon")// 完成下载的图
    
    var name: String?
    
    var length: String?
    
    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    private var documentInteractionController: UIDocumentInteractionController!
    
    private var baseViewController: UIViewController!
    
    private var messageId: String!
    
    private var source: FileMessageSource!
    
    private var isLocallyStored: Bool = false
    
    private var bubbleController: BubbleController!
    
    private var downloadRequest: FileDownloadRequest?
        
    weak var view: FileView? {
        didSet {
            if isLocallyStored {
                status = .completion
            }
            view?.reloadData()
        }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            view?.reloadData()
        }
    }
    
    var status: FileDownloadStatus = .normal
    
    func pause() {
        status = .paused
        downloadRequest?.request.suspend()
    }
    
    func resume() {
        status = .downloading
            
        if downloadRequest == nil {
            loadFile()
        } else {
            downloadRequest?.request.resume()
        }
    }
    
    func cancel() {
        downloadRequest?.request.cancel()
    }
    
    func prepareForReuse(reStart: Bool = true) {
        if let req = FileDownloadManager.manager.downloadRequest(messageID: messageId) {
            downloadRequest = req
            FileDownloadManager.manager.setExistsTaskHandler(messageID: messageId) { [self] (messageID, written, total) in
                
                guard self.messageId == messageID else { return }
                
                DispatchQueue.main.async { [self] in
                    self.progress = CGFloat(written) / CGFloat(total)
                }
            } completion: { [weak self] (messageID, url) in
                FileHelper.shared.saveFile(from: url.path, name: self?.name)
                
                DispatchQueue.main.async { [self] in
                    guard let self else { return }
                    self.status = .completion
                    self.view?.reloadData()
                    self.delegate?.reloadMessage(with: self.messageId)
                }
            }
            if reStart {
                resume()
            }
        }
    }

    init(source: FileMessageSource, isLocallyStored: Bool, messageId: String, bubbleController: BubbleController) {
        super.init()
        self.name = source.name
        self.source = source
        self.messageId = messageId
        self.bubbleController = bubbleController
        self.length = FileHelper.formatLength(length: source.length)
        self.obtainIconImage(url: source.url)
        self.isLocallyStored = isLocallyStored
        
        prepareForReuse()
    }
    
    private func loadFile() {
        
        if isLocallyStored {
            status = .completion
            view?.reloadData()
        } else {
            downloadRequest = FileDownloadManager.manager.downloadMessageFile(messageID: messageId,
                                                                              url: source.url,
                                                                              name: name) { [self] (messageID, written, total) in
                
                guard self.messageId == messageID else { return }
                
                DispatchQueue.main.async { [self] in
                    self.progress = CGFloat(written) / CGFloat(total)
                }
            } completion: { [weak self] (messageID, url) in
                FileHelper.shared.saveFile(from: url.path, name: self?.name)
                
                DispatchQueue.main.async { [self] in
                    guard let self else { return }
                    self.status = .completion
                    self.view?.reloadData()
                    self.delegate?.reloadMessage(with: self.messageId)
                }
            }
        }
    }
    
    private func obtainIconImage(url: URL) {
        let ext = url.relativeString.split(separator: ".").last
        switch ext {
        case "xls", "xlsx":
            image = UIImage(nameInBundle: "chat_msg_file_excel_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_excel_normal_icon")
        case "ppt", "pptx":
            image = UIImage(nameInBundle: "chat_msg_file_ppt_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_ppt_normal_icon")
        case "doc", "docx":
            image = UIImage(nameInBundle: "chat_msg_file_word_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_word_normal_icon")
        case "pdf":
            image = UIImage(nameInBundle: "chat_msg_file_pdf_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_pdf_normal_icon")
        case "zip", "rar", "7z":
            image = UIImage(nameInBundle: "chat_msg_file_zip_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_zip_normal_icon")
        default:
            image = UIImage(nameInBundle: "chat_msg_file_unknown_disable_icon")
            highlightedImage = UIImage(nameInBundle: "chat_msg_file_unknown_normal_icon")
        }
    }
    
    func action() {
        
        if let path = FileHelper.shared.exsit(path: source.url.relativeString, name: name) {
            let url = URL(fileURLWithPath: path)
            showFile(url: url)
        } else {
            if status == .downloading {
                pause()
            } else {
                resume()
            }
            view?.reloadData()
        }
    }
    
    private func showFile(url: URL) {
        baseViewController = currentViewController()
        documentInteractionController = UIDocumentInteractionController(url: url)
        documentInteractionController.delegate = self
        
        DispatchQueue.main.async { [self] in
            // 有些文件不能预览，就选择分享界面
            let r = documentInteractionController.presentPreview(animated: true)
            if !r {
                documentInteractionController.presentOptionsMenu(from: baseViewController.view.bounds, in: baseViewController.view, animated: true)
            }
        }
    }
    
    private func currentViewController() -> UIViewController {
        var rootViewController: UIViewController?
        for window in UIApplication.shared.windows {
            if window.rootViewController != nil {
                rootViewController = window.rootViewController
                break
            }
        }
        var viewController = rootViewController
        if viewController?.presentedViewController != nil {
            viewController = viewController!.presentedViewController
        }
        return viewController!
    }
}

extension FileController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return baseViewController
    }
    
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return baseViewController.view
    }
    
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return baseViewController.view.frame
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        print("Dismissed!!!")
    }
}
