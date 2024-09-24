
import Foundation

final class YFBokeController {
    var faceURL: String?
    
    var name: String?
    
    var intro: String?

    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    private let source: bokeMessageSource

    private let messageId: String
    
    private let bubbleController: BubbleController
    
    weak var view: YFBokeView? {
        didSet {
            view?.reloadData()
        }
    }

    init(source: bokeMessageSource, messageID: String, bubbleController: BubbleController) {
        self.source = source
        self.messageId = messageID
        self.bubbleController = bubbleController
        configData()
    }
    
    private func configData() {
        self.name = source.title
        self.faceURL = source.iconUrl
        self.intro = source.intro
    }
    
    func action() {
//        delegate?.didTapContent(with: messageId, data: .card(source))
        let customsource =  CustomMessageSource(data: getCustomBokeData(source))
        delegate?.didTapContent(with: messageId, data: .custom(customsource))
    }
    
    func getCustomBokeData(_ source: bokeMessageSource) -> String {
  
        let parm  = ["customType": 10500, "data": ["title": source.title,"iconUrl": source.iconUrl, "linkUrl":source.linkUrl, "intro": source.intro]] as [String : Any]
        
        do {
            let datastr = String.init(data: try JSONSerialization.data(withJSONObject: parm), encoding: .utf8)
            return datastr!
        } catch {
            return ""
        }
        
    }
}
