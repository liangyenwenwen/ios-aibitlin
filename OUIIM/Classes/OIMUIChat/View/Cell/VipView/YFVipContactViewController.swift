//
//  YFVipContactViewController.swift
//  OUIIM
//
//  Created by mac on 2024/9/3.
//

import Foundation

final class YFVipContactViewController {
    
    weak var delegate: ReloadDelegate?

    let text: String?
    
    let attributedString: NSAttributedString?
    
    let enableBackgroundColor: Bool

    init(text: String? = nil, attributedString: NSAttributedString? = nil, enableBackgroundColor: Bool = false) {
        self.text = text
        self.attributedString = attributedString
        self.enableBackgroundColor = enableBackgroundColor
    }
    
    func action(url: URL) {
        delegate?.didTapContent(with: "", data: .url(url, isLocallyStored: false))
    }
    
//    weak var delegate: ReloadDelegate?
//        
//    let source: NoticeMessageSource
//    
//    private let messageID: String
//    private let bubbleController: BubbleController
//
//    init(messageID: String, source: NoticeMessageSource, bubbleController: BubbleController) {
//        self.messageID = messageID
//        self.source = source
//        self.bubbleController = bubbleController
//    }
//    
//    func action() {
//        delegate?.didTapContent(with: messageID, data: .notice(source))
//    }
}

