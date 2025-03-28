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
import NSObject_Rx
import OUICoreView
import  ProgressHUD



enum blogListVCType :Int {
    case meWebsite  = 0
    case othersBlog 
    case star
}


class MineBokeListViewController: BaseTitleController {

    var vcType: blogListVCType = .meWebsite
    var isEidt = false
    var othersID: String?
    var othersName: String?
    var page:Int = 1
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.white)
        initTableViewSafeAre()
        
       
//        tableViewAddEmptyView()
        isNeedEmptyView()

        switch vcType {
        case .meWebsite:
            title = "MeWebsite".localized()
        case .othersBlog:
            title = "UserWebsite".localizedFormat(othersName ?? "")
        case .star:
            title = "我收藏的网站".localized()
        }
        tableView.register(MineBokeListCell.self, forCellReuseIdentifier: MineBokeListCell.className)
        
        if vcType == .meWebsite {
            superFooterContainerContainer.tg_padding = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            superFooterContainerContainer.addSubview(bottomBtn)
        }
        
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
        let footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
        header.stateLabel?.isHidden = true
        header.lastUpdatedTimeLabel?.isHidden = true
        tableView.mj_header = header
        tableView.mj_footer = footer
        refreshData()
    }
    
    
    
    
    
    lazy var sortBtn:  QMUIButton = {
        let r = ViewFactoryUtil.linkButton()
        r.setTitle("Sort".localized(), for: .normal)
        r.setTitleColor(.colorPrimary, for: .normal)
        r.sizeToFit()
        r.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.changeSortState()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    func changeSortState() {
        self.vcType = .meWebsite
        self.isEidt.toggle()
        self.tableView.isEditing = self.isEidt 
        self.tableView.reloadData()
        self.sortBtn.setTitle(self.isEidt ? "完成".localized() : "排序".localized(), for: .normal)
        self.sortBtn.sizeToFit()
    }
    
    lazy var bottomBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("Add".localized(), for: .normal)
        r.imagePosition = .left
        r.setImage(R.image.add_circle_icon()!, for: .normal)
        r.spacingBetweenImageAndTitle = 12
        r.rx.tap.subscribe(onNext: { [weak self] _ in
            let vc = MineBokeEditVC()
            vc.refreshMineBokeList = { [weak self] in
                self?.refreshData()
            }
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    

}

extension MineBokeListViewController {
 
 
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        emptyView.hide()
        let cell = tableView.dequeueReusableCell(withIdentifier: MineBokeListCell.className, for: indexPath) as! MineBokeListCell
        cell.bindData(datum[indexPath.row] as! myBlogShowBlogPOModel)
        cell.editBlock = { [weak self] in
            self?.showEdit(indexPath.row)
        }
        if(vcType == .othersBlog) {
            cell.isClean()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = datum[indexPath.row] as! myBlogShowBlogPOModel
        SuperWebController.startAboubBlog(self.navigationController!, blogItem: item)
    }

    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempIndex = datum[sourceIndexPath.row]
        datum.remove(at: sourceIndexPath.row)
        datum.insert(tempIndex, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (vcType == .meWebsite && isEidt)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return vcType == .meWebsite
    }
    
    
    ///移除左侧按钮
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    
    ///移除左侧空白
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }
    
    
    
   
}

extension MineBokeListViewController {
    
    @objc func refreshData() {
        
        switch vcType {
        case .meWebsite:
            getMyBlog(page: 1)
        case .othersBlog:
            othersSeeMyBlog(page: 1)
        case .star:
        self.datum = YFFileDataUtil.readDataToFile()
            tableView.reloadData()
            tableView.mj_header?.endRefreshing()
            break
        }
        
    }
    @objc func loadMoreData() {
        switch vcType {
        case .meWebsite:
            getMyBlog(page: page+1)
        case .othersBlog:
            othersSeeMyBlog(page: page+1)
        case .star:
            tableView.reloadData()
        }
    }
    
    
    
    func showEdit(_ index: Int)  {
        let contentView = MineBokeFooterEditView(type: vcType)
        contentView.blogItem = datum[index] as! myBlogShowBlogPOModel
        contentView.update()
        contentView.tg_width.equal(.fill)
        contentView.tg_height.equal(view.frame.height / 2)
        GKCover.cover(from: view, contentView: contentView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        
        contentView.editBoke = { [weak self] item in
            let vc = MineBokeEditVC()
            vc.isEdit = true
            vc.blogItem = item
            vc.refreshMineBokeList = { [weak self] in
                self?.refreshData()
            }
            self?.navigationController?.pushViewController(vc, animated: true)
            GKCover.hideWithoutAnimation()
        }
        
        ///显示在主页
        contentView.showBokeOnHome = { [weak self] item,show in
            if show {
                YFFileDataUtil.saveOneDataToFile(.home, blogItem: item)
            } else {
                YFFileDataUtil.deleteOneDataFromFile(.home, blogItem: item)
            }
            
        }
        
        contentView.deleteBoke = { [weak self] item in
            print("删除")
            self?.presentAlert(title: "deletWebsiteTip".localized()) { [weak self] in
                GKCover.hideWithoutAnimation()
                self?.deleteBlog(item: item)
            }
            
        }
        
//        contentView.shareBlog = { [weak self] blogItem in
//            print(blogItem.base?.info?.name)
//            
//            let vc = MyContactsViewController(types: [.friends])
//            vc.allowsSelecteAll = false
//            
//            vc.selectedContact { [weak self, weak vc] info in
//                guard let self, let vc, let user = info.first else { return }
//
//                IMController.shared.sendBokeMessage(boke: blogItem.base?.info?.toBokeElem()!, to: user.ID!, conversationType: .c2c) { _ in
//                    
//                } onComplete: { _ in
//                    vc.dismiss(animated: true)
//                    GKCover.hideWithoutAnimation()
//                    SuperToast.show(title: "sentSuccess".localized())
//                    
//                }
//
//                
//            }
//            
//            let nav = UINavigationController(rootViewController: vc)
//            self?.present(nav, animated: true)
//        }
        
        contentView.topBlog = { [weak self] item in
            GKCover.hide()
            self?.topBlog(item: item)
        }
        
        contentView.reportBoke = { [weak self] item in
            print("举报")
            GKCover.hide()
            let vc = YFFeedbackVC()
            vc.reportType = .blog
            self?.gotoController(vc)
            GKCover.hideWithoutAnimation()
        }
    }
    
    
    func getMyBlog(page:Int = 1) {
        
        if let IMUser = IMController.shared.currentUserRelay.value {
            YFMineNetViewModel.mineBlog(limit: "20", page: String(page), hash: "") { [weak self] data in
                DispatchQueue.main.async {
                    self?.page = page
                    if page == 1 {
                        YFFileDataUtil.saveDataToFile(.cache, blogsArr: data ?? [])
                        self?.datum = data ?? []
                    }else{
                        self?.datum.append(contentsOf: data ?? [])
                    }
                    if data?.count ?? 0 < 20{
                        self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    }else{
                        self?.tableView.mj_footer?.endRefreshing()
                    }
                    self?.tableView.mj_header?.endRefreshing()
                    self?.tableView.reloadData()
                }
            } completionHandler: { errCode, errMsg in
                self.tableView.mj_header?.endRefreshing()
            }
            
        }
    }
    
    func othersSeeMyBlog(page:Int = 1) {
        if let userId = othersID {
            
            YFMineNetViewModel.otherSeeMyBlog(limit: "20", page: String(page),uid:userId, hash: "",pwd:"") { [weak self] data in
                self?.page = page
                if page == 1 {
                    self?.datum = data ?? []
                }else{
                    self?.datum.append(contentsOf: data ?? [])
                }
                if data?.count ?? 0 < 20{
                    self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else{
                    self?.tableView.mj_footer?.endRefreshing()
                }
                self?.tableView.mj_header?.endRefreshing()
                self?.tableView.reloadData()
            } completionHandler: { errCode, errMsg in
                self.tableView.mj_header?.endRefreshing()
            }
        }
    }
    
    func topBlog(item: myBlogShowBlogPOModel) {
        YFMineNetViewModel.blogTop(paramters: ["hash":item.base?.hash ?? ""]) { errCode, errMsg in
            if errCode == 200 {
                self.getMyBlog(page: 1)
            } else {
                SuperToast.show(title: errMsg?.localized())
            }
        }
    }
    
    func deleteBlog(item: myBlogShowBlogPOModel) {
        
        if vcType == .star {
            datum = YFFileDataUtil.deleteOneDataFromFile(blogItem: item)
            self.tableView.reloadData()
        } else {
            let parameters: [String:Any] = ["hash":item.base?.hash ?? ""]
                YFMineNetViewModel.deleteBlog(paramters: parameters) { errCode, errMsg in
                    if errCode == 200 {
                        self.getMyBlog(page: 1)
                    } else{
                        SuperToast.show(title: errMsg?.localized())
                    }
                }
        }
    }
}
