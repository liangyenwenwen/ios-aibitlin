
import Foundation
import Kingfisher

final class ReplyViewController {
    
    lazy var quoteAttributedString = NSMutableAttributedString(string: "\(source.sender!)：")

    weak var view: ReplyView? {
        didSet {
            view?.reloadData()
        }
    }

    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    let sender: String?
    
    let text: String?
    
    let attributedString: NSAttributedString?
    
    var attachmentImage: UIImage?
    
    var isVideo: Bool = false
    
    let quoteData: Message.Data?
    
    let type: MessageType
    
    private let source: QuoteMessageSource
    
    let messageID: String

    private let bubbleController: BubbleController

    init(source: QuoteMessageSource, messageID: String, type: MessageType, bubbleController: BubbleController) {
        self.text = source.text
        self.attributedString = source.attributedString
        self.sender = source.sender
        self.quoteData = source.quote
        self.source = source
        self.type = type
        self.messageID = messageID
        self.bubbleController = bubbleController
        configData()
    }
    
    private func configData() {
        attachmentImage = nil
        
        guard let quote = source.quote else { return }
        
        switch quote {
        case .text(let source):
            quoteAttributedString.append(NSAttributedString(string: source.text))
            
        case .attributeText(let text):
            quoteAttributedString.append(text)
            
        case .mention(let source):
            quoteAttributedString.append(source.attributedString!)
            
        case .url(_, isLocallyStored: let isLocallyStored):
            break
            
        case .image(let s, isLocallyStored: let isLocallyStored):
            loadImage(thumbURL: s.source.url.customThumbnailURL()) { [weak self] image in
                guard let self else { return }
                
                attachmentImage = image
                view?.reloadData()
            }
            
        case .video(let s, isLocallyStored: let isLocallyStored):
            isVideo = true
            
            loadImage(thumbURL: s.thumb?.url.customThumbnailURL()) { [weak self] image in
                guard let self else { return }
                
                attachmentImage = image
                view?.reloadData()
            }
            
        case .audio(let s, isLocallyStored: let isLocallyStored):
            let attachStr = buildAttachmentString(image: UIImage(nameInBundle: "chat_msg_audio_record_normal"))
            quoteAttributedString.append(attachStr)
            quoteAttributedString.append(NSAttributedString(string: #"\#(s.duration!)"#))
            view?.reloadData()
            
        case .file(let s, isLocallyStored: let isLocallyStored):
            quoteAttributedString.append(NSAttributedString(string: "\(s.name!)"))
            let attachStr = buildAttachmentString(image: UIImage(nameInBundle: "chat_msg_file_zip_normal_icon"))
            quoteAttributedString.append(attachStr)
            view?.reloadData()
            
        case .merge(_):
            quoteAttributedString.append(NSAttributedString(string: "[\("聊天记录".innerLocalized())]"))
            view?.reloadData()
            
        case .card(let s):
            quoteAttributedString.append(NSAttributedString(string: "[\("名片".innerLocalized())] \(s.user.name)"))
            view?.reloadData()
            
        case .location(let s):
            quoteAttributedString.append(NSAttributedString(string: "[\("位置".innerLocalized())]\(s.address ?? "") "))
            let attachStr = buildAttachmentString(image: UIImage(nameInBundle: "chat_msg_location_normal"), rect: CGRect(x: 0, y: -5, width: 16, height: 20))
            quoteAttributedString.append(attachStr)
            
            view?.reloadData()
        case .face(let s, isLocallyStored: let isLocallyStored):
            loadImage(thumbURL: s.url.customThumbnailURL()) { [weak self] image in
                guard let self else { return }
                
                attachmentImage = image
                view?.reloadData()
            }
         
        case .custom(_), .quote(_), .notice(_):
            break
//             MARK: -    博客configData
//        case .boke(_):
//            print("博客configData", #file, #line)
//            break
        }
    }
    
    private func loadImage(thumbURL: URL?, completion: @escaping (UIImage) -> Void) {
        
        guard let thumbURL else { return }
        
        DefaultImageCacher.loadImage(url: thumbURL, thumbURL: thumbURL) { [self] i in
            attachmentImage = i
            view?.reloadData()
        }
    }
    
    private func buildAttachmentString(image: UIImage?, rect: CGRect = CGRect(x: 0, y: -5, width: 20, height: 20)) -> NSAttributedString {
        
        guard let image else { return NSAttributedString() }
        
        var attach = NSTextAttachment()
        attach.bounds = rect
        attach.image = image
        let attachStr = NSMutableAttributedString(attachment: attach)
        
        return attachStr
    }
    
    func action(url: URL) {
        delegate?.didTapContent(with: messageID, data: .url(url, isLocallyStored: false))
    }
    
    func quoteMessageAction() {
        if let attachmentImage {
            delegate?.didTapContent(with: messageID, data: .quote(source))
        } else {
            delegate?.didTapContent(with: messageID, data: source.quote!)
        }
    }
}
