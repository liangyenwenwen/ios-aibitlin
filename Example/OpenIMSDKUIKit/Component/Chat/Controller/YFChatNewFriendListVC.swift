//
//  YFChatNewFriendListVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/26.
//  Copyright © 2024 rentsoft. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa
import OUICore
import OUIIM

class YFChatNewFriendListVC: BaseTitleController {

    var vcType: MyStyle = .bokeVisitorStranger
    var boke : myBlogShowBlogPOModel!
    var blogTime: String!
    var paramters : [String : Any]!
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.white)
        initTableViewSafeAre()

        title = "新关注我的朋友".localized()
        
        tableView.register(MineBokeVisitorListCell.self, forCellReuseIdentifier: MineBokeVisitorListCell.className)
        

    }
    
}

extension YFChatNewFriendListVC {
 
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineBokeVisitorListCell.className, for: indexPath) as! MineBokeVisitorListCell
//        cell.bindData(datum[indexPath.row] as! BlogVisitorListModel)
        cell.updateAboutChat()

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 72
//    }
}

extension YFChatNewFriendListVC {
    
    

    
    func toChat(sourceId: String) {
        IMController.shared.getConversation(sessionType: .c2c, sourceId: sourceId) { [weak self] (conversation: ConversationInfo?) in
            guard let conversation else { return }

            let vc = ChatViewControllerBuilder().build(conversation, hiddenInputBar: false)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

