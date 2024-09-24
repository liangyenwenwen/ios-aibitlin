//
//  MineBokeListViewController.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/6.
//

import UIKit
import RxSwift
import RxCocoa
import OUICore

class MineBokeListViewController: BaseTitleController {

    var isMe = true
    var isEidt = false
    var othersID: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isMe {
            getMyBlog()
        } else {
            othersSeeMyBlog()
        }
    }
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.white)
        initTableViewSafeAre()

        title = R.string.localizable.meBlog()

        
        tableView.register(MineBokeListCell.self, forCellReuseIdentifier: MineBokeListCell.className)
//        tableView.isEditing = isMe
//        tableView.dragInteractionEnabled = true
        
        if isMe {
            superFooterContainerContainer.tg_padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            superFooterContainerContainer.addSubview(bottomBtn)
        }
        
//        if isMe {
//            navView.addRighttItem(sortBtn)
//        }

    }
    
    lazy var sortBtn:  QMUIButton = {
        let r = ViewFactoryUtil.linkButton()
        r.setTitle(R.string.localizable.sort(), for: .normal)
        r.setTitleColor(.colorPrimary, for: .normal)
        r.sizeToFit()
        r.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.changeSortState()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    func changeSortState() {
        self.isMe = true
        self.isEidt.toggle()
        self.tableView.isEditing = self.isEidt 
        self.tableView.reloadData()
        self.sortBtn.setTitle(self.isEidt ? "完成".localized() : "排序".localized(), for: .normal)
        self.sortBtn.sizeToFit()
    }
    
    lazy var bottomBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle(R.string.localizable.add(), for: .normal)
        r.imagePosition = .left
        r.setImage(R.image.add_circle_icon()!, for: .normal)
        r.spacingBetweenImageAndTitle = 12
        r.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.navigationController?.pushViewController(MineBokeEditVC(), animated: true)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    

}

extension MineBokeListViewController {
 
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MineBokeListCell.className, for: indexPath) as! MineBokeListCell
        cell.bindData(datum[indexPath.row] as! blogDetailItem)
        cell.editBlock = { [weak self] in
            self?.showEdit(indexPath.row)
        }
        if(!isMe) {
            cell.isClean()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(!isMe) {
            let item = datum[indexPath.row] as! blogDetailItem
            SuperWebController.start((self.navigationController!), uri: item.userBlogUrl)
        } else {
            let vc = MineBokeStatisticsVC()
            let item = datum[indexPath.row] as! blogDetailItem
            vc.boke = item
            navigationController?.pushViewController(vc)
        }
        
    }
    

    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempIndex = datum[sourceIndexPath.row]
        datum.remove(at: sourceIndexPath.row)
        datum.insert(tempIndex, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (isMe && isEidt)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return isMe
    }
    
    
    ///移除左侧按钮
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    
    ///移除左侧空白
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
    
    
    
    func showEdit(_ index: Int)  {
        let contentView = MineBokeFooterEditView(isMe: isMe)
        contentView.blogItem = datum[index] as! blogDetailItem
        contentView.tg_width.equal(.fill)
        contentView.tg_height.equal(view.frame.height / 2)
        GKCover.cover(from: view, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        
        contentView.editBoke = { [weak self] item in
            let vc = MineBokeEditVC()
            vc.isEdit = true
            vc.blogItem = item
            self?.navigationController?.pushViewController(vc, animated: true)
            GKCover.hideWithoutAnimation()
        }
        
        contentView.showBokeOnHome = { [weak self] item,show in
            GKCover.hideWithoutAnimation()
            print(show)
        }
        
        contentView.deleteBoke = { [weak self] item in
            GKCover.hideWithoutAnimation()
            print("删除")
            self?.deleteBlog(item: item)
        }
        
        contentView.topBlog = { [weak self] item in
            GKCover.hide()
            self?.topBlog(item: item)
        }
        
        contentView.reportBoke = { [weak self] item in
            print("举报")
            GKCover.hide()
            let vc = YFFeedbackVC()
            vc.useType = .useReport
            self?.gotoController(vc)
            GKCover.hideWithoutAnimation()
        }
    }
    
    
    func getMyBlog() {
        
        if let IMUser = IMController.shared.currentUserRelay.value {
            
            YFMineNetViewModel.mineBlog(userId: IMUser.userID) { [weak self] data in
                self?.datum = data
                self?.tableView.reloadData()
            } completionHandler: { errCode, errMsg in
                
            }
        }
    }
    
    func othersSeeMyBlog() {
        if let userId = othersID {
            
            YFMineNetViewModel.otherSeeMyBlog(userId: userId) { [weak self] data in
                self?.datum = data
                self?.tableView.reloadData()
            } completionHandler: { errCode, errMsg in
                
            }
        }
    }
    
    func topBlog(item: blogDetailItem) {
        YFMineNetViewModel.blogTop(paramters: ["sign":item.sign, "blogId":item.id, "userId":item.userId]) { errCode, errMsg in
            if errCode == 20000 {
                self.getMyBlog()
            } else {
                SuperToast.show(title: R.string.localizable.failure())
            }
        }
    }
    
    func deleteBlog(item: blogDetailItem) {
        let parameters: [String:Any] = ["userBlogId":item.id, "sign":item.sign]
        YFMineNetViewModel.deleteBlog(paramters: parameters) { errCode, errMsg in
            if errCode == 20000 {
                self.getMyBlog()
            } else {
                SuperToast.show(title: R.string.localizable.failure())
            }
        }
    }
}
