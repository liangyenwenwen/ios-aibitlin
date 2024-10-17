
import Foundation

final class SystemTipsViewController {
    
    weak var delegate: ReloadDelegate?

    let text: String?
    
    let attributedString: NSAttributedString?
    
    let enableBackgroundColor: Bool
    
    let needHide: Bool

    init(text: String? = nil, attributedString: NSAttributedString? = nil, enableBackgroundColor: Bool = false, needHide: Bool = false) {
        self.text = text
        self.attributedString = attributedString
        self.enableBackgroundColor = enableBackgroundColor
        self.needHide = needHide
    }
    
    func action(url: URL) {
        delegate?.didTapContent(with: "", data: .url(url, isLocallyStored: false))
    }
}
