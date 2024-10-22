//
//  MineBokeVisitorListVC.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/9/6.
//  Copyright © 2024 rentsoft. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa
import OUICore
import OUIIM

class MineBokeVisitorListVC: BaseTitleController {

    var vcType: MyStyle = .bokeVisitorStranger
    var boke : blogDetailItem!
    var blogTime: String!
    var paramters : [String : Any]!
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.white)
        initTableViewSafeAre()
        isNeedEmptyView()

        title = vcType == .bokeVisitorFriend ? "好友访客".localized() : "陌生人访客".localized()
        
        tableView.register(MineBokeVisitorListCell.self, forCellReuseIdentifier: MineBokeVisitorListCell.className)
        
        netWork()
        
        isNeedEmptyView()

    }
    
}

extension MineBokeVisitorListVC {
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineBokeVisitorListCell.className, for: indexPath) as! MineBokeVisitorListCell
        cell.bindData(datum[indexPath.row] as! BlogVisitorListModel)
        cell.toChatBlock = { [weak self] id in
            self?.toChat(sourceId: id)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }

}



extension MineBokeVisitorListVC {
    
    func netWork() {
        if vcType == .bokeVisitorFriend {
            friendNetWork()
        } else {
            strangersNetWork()
        }
    }
    
    func friendNetWork() {
        let paramters : [String: Any] = ["time": blogTime!, "userId": boke.userId, "userBlogId": boke.id]
        
        YFMineNetViewModel.queryShowBlogsSurveyFriends(paramters: paramters) { [self]data in
            datum = data
            tableView.reloadData()
        } completionHandler: { errCode, errMsg in
        
        }

    }
    
    func strangersNetWork() {
        let paramters : [String: Any] = ["time": blogTime!, "userId": boke.userId!, "userBlogId": boke.id!]
        
        YFMineNetViewModel.queryShowBlogsSurveyStranger(paramters: paramters) { [self]data in
            datum = data
            tableView.reloadData()
        } completionHandler: { errCode, errMsg in
        
        }

    }

    
    func toChat(sourceId: String) {
        IMController.shared.getConversation(sessionType: .c2c, sourceId: sourceId) { [weak self] (conversation: ConversationInfo?) in
            guard let conversation else { return }

            let vc = ChatViewControllerBuilder().build(conversation, hiddenInputBar: false)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
