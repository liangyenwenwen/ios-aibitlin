//
//  YFVipNormalController.swift
//  OUIIM
//
//  Created by mac on 2024/9/3.
//


import Foundation

final class YFVipNormalViewController {
    
//    weak var delegate: ReloadDelegate?
//
//    let text: String?
//    
//    let attributedString: NSAttributedString?
//    
//    let enableBackgroundColor: Bool
//
//    init(text: String? = nil, attributedString: NSAttributedString? = nil, enableBackgroundColor: Bool = false) {
//        self.text = text
//        self.attributedString = attributedString
//        self.enableBackgroundColor = enableBackgroundColor
//    }
//    
//    func action(url: URL) {
//        delegate?.didTapContent(with: "", data: .url(url, isLocallyStored: false))
//    }
    
    weak var delegate: ReloadDelegate?
        
    var source: NoticeMessageSource
    
    let message: Message
//    private let bubbleController: BubbleController

    init(message: Message, source: NoticeMessageSource) {
        self.message = message
        self.source = source
    }
    
    func action() {
        delegate?.didTapContent(with: message.id, data: .notice(source))
    }
}
