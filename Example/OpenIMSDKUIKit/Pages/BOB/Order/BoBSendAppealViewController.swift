//
//  BoBSendAppealViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/26.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBSendAppealViewController: BaseTitleController {
    var code:String = ""
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func initViews() {
        super.initViews()
        setBackGroundColor(.white)
        initScrollSafeArea()
        title = "发起申诉"
        scrollViewContainer.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
    }
}
