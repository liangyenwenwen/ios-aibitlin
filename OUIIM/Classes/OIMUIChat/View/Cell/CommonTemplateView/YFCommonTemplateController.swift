//
//  YFCommonTemplateController.swift
//  Alamofire
//
//  Created by mac on 2025/4/8.
//

import OUICore

final class YFCommonTemplateController {
        


    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    var source: CustomMessageSource
    var messageSource:commonTemplateMessageSource
    
    private let messageId: String
    
    private let bubbleController: BubbleController
    
    
    
    weak var view: YFCommonTemplateView? {
        didSet {
            view?.reloadData(messageSource:messageSource)
        }
    }
    init(source: CustomMessageSource, messageID: String, bubbleController: BubbleController) {
        self.source = source
        self.messageSource = source.commonTemplateMessageSource
        self.messageId = messageID
        self.bubbleController = bubbleController
    }
    func action(type:String) {
        delegate?.clickPublicCustomerMessage(with: messageId, type:type,data: .custom(self.source))
    }
}

