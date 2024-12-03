//
//  BoBSendRedPacketViewController.swift
//  Alamofire
//
//  Created by mac on 2024/12/3.
//

import Foundation

class BoBSendRedPacketViewController: BaseTitleController {
    override func initViews() {
        super.initViews()
        setBackGroundColor(.init(hexString: "#388CEF"))
        initScrollSafeArea()
        title = "红包"
        scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        scrollViewContainer.tg_space = 10
        superFooterContainerContainer.tg_bottom.equal(0)

    }
}
