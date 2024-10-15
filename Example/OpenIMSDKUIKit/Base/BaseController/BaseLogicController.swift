//
//  BaseLoginController.swift
//  项目中通用的逻辑控制器
//
//  Created by mac on 2024/4/24.
//

import UIKit
import TangramKit
import RxRelay

class BaseLogicController: BaseCommentController {
    
    ///跟容器
    var rootContainer: TGBaseLayout!
    
    ///头部容器
    var superHeaderContainer: TGBaseLayout!
    var superHeaderContainerContainer: TGBaseLayout!
    
    ///内容容器
    var container: TGBaseLayout!
    
    ///底部容器
    var superFooterContainer: TGBaseLayout!
    var superFooterContainerContainer: TGBaseLayout!
    
    //tableView
    var tableView: UITableView!
    
    var scrollView: UIScrollView!
    var scrollViewContainer: TGLinearLayout!
    
    var isHaveEmpty: Bool = false
    lazy var emptyView: YFEmptyView = {
        let r = YFEmptyView()
        return r
    }()
    
    lazy var topBg: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "user_meesage_top_bg")
        r.contentMode = .scaleAspectFill
        return r
    }()
    
//    var datum : BehaviorRelay<[Any]> = .init(value: [])
    
    lazy var  datum: [Any] = {
        var reslut: [Any] = []
        return reslut
    }()
    
    ///初始化RelativeLayout容器 四边都在安全区内
    func initRelativeLayoutSafeArea()  {
        initLinerLayout()
        
        //header
        initHeaderContainer()
        
        container = TGRelativeLayout()
        container.tg_width.equal(.fill)
        container.tg_height.equal(.fill)
        container.backgroundColor = .clear
        rootContainer.addSubview(container)
        
        
        //footer
        initFooterContainer()
    }
    
    ///初始化垂直方向的容器 四边都在安全区
    func initLinearLayoutSafeArea()  {
        initLinerLayout()
        
        //header
        initHeaderContainer()
        
        container = TGLinearLayout(.vert)
        container.tg_width.equal(.fill)
        container.tg_height.equal(.fill)
        container.backgroundColor = .clear
        rootContainer.addSubview(container)
        
        
        //footer
        initFooterContainer()
    }
    
    ///初始化tableView
    func initTableViewSafeAre(_ style: UITableView.Style = .plain) {
        //初始化四周再安全区域内的容器
        initLinearLayoutSafeArea()
        createTableView(style)
        
    }
    
    ///初始化tableView  定制  tableView可以显示在 nav下面
    func initTableViewSafeAreCustom(_ style: UITableView.Style = .plain) {
        //初始化四周再安全区域内的容器
        initRelativeLayoutSafeAreaAboutTab()
        createTableView(style)
        
    }
    ///初始化RelativeLayout容器 四边都在安全区内
    func initRelativeLayoutSafeAreaAboutTab()  {
        initRelativeayout()
        
        
        
        
        //footer
        initFooterContainer(true)
        
        container = TGLinearLayout(.vert)
        container.tg_top.equal(0)
        container.tg_left.equal(0)
        container.tg_right.equal(0)
        container.tg_bottom.equal(superFooterContainer.tg_top)
        container.backgroundColor = .clear
        rootContainer.addSubview(container)
        
        
        //header
        initHeaderContainer(true)
        
    }
    
    
    
    func initScrollSafeArea()  {
        initLinearLayoutSafeArea()
        
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator  = false
        scrollView.tg_width.equal(.fill)
        scrollView.tg_height.equal(.fill)
        container.addSubview(scrollView)
        
        scrollViewContainer = TGLinearLayout(.vert)
        scrollViewContainer.tg_width.equal(.fill)
        scrollViewContainer.tg_height.equal(.wrap)
        scrollView.addSubview(scrollViewContainer)
    }
    
    func createTableView(_ style: UITableView.Style = .plain) {
        tableView = ViewFactoryUtil.tableView(style)
        tableView.delegate = self
        tableView.dataSource = self
        container.addSubview(tableView)
    }
    
    func initDefalutTableViewDivider()  {
        tableView.separatorStyle = .singleLine
    }
    
    
    ///初始化垂直方向的LinerLayout容器
    func initLinerLayout()  {
        rootContainer = TGLinearLayout(.vert)
        rootContainer.tg_width.equal(.fill)
        rootContainer.tg_height.equal(.fill)
        rootContainer.backgroundColor = .clear
        view.addSubview(rootContainer)
    }
    
    ///初始化垂直方向的LinerLayout容器
    func initRelativeayout()  {
        rootContainer = TGRelativeLayout()
        rootContainer.tg_top.equal(0)
        rootContainer.tg_bottom.equal(0)
        rootContainer.tg_left.equal(0)
        rootContainer.tg_right.equal(0)
        rootContainer.backgroundColor = .clear
        view.addSubview(rootContainer)
    }
    
    
    ///头部容器 安全域外 一般来设置头部安全域外背景颜色
    func initHeaderContainer(_ isRelative: Bool = false) {
        superHeaderContainer = TGLinearLayout(.vert)
        superHeaderContainer.tg_width.equal(.fill)
        superHeaderContainer.tg_height.equal(.wrap)
        superHeaderContainer.backgroundColor = .clear
        
        if(isRelative) {
            superHeaderContainer.tg_top.equal(0)
        }
        
        //头部内容器 安全区域内
        superHeaderContainerContainer = TGLinearLayout(.vert)
        if isRelative {
            superHeaderContainerContainer.tg_height.equal(52)
        } else {
            superHeaderContainerContainer.tg_height.equal(.wrap)
        }
       
        superHeaderContainerContainer.tg_leading.equal(TGLayoutPos.tg_safeAreaMargin)
        superHeaderContainerContainer.tg_top.equal(TGLayoutPos.tg_safeAreaMargin)
        superHeaderContainerContainer.tg_trailing.equal(TGLayoutPos.tg_safeAreaMargin)
        superHeaderContainerContainer.backgroundColor = .clear
        
        superHeaderContainer.addSubview(superHeaderContainerContainer)
        rootContainer.addSubview(superHeaderContainer)
    }
    
    ///低部容器 安全域外 一般来设置头部安全域外背景颜色
    func initFooterContainer(_ isRelative: Bool = false) {
        superFooterContainer = TGLinearLayout(.vert)
        superFooterContainer.tg_width.equal(.fill)
        superFooterContainer.tg_height.equal(.wrap)
        superFooterContainer.backgroundColor = .clear
        
        if(isRelative) {
            superFooterContainer.tg_bottom.equal(0)
        }
        
        //头部内容器 安全区域内
        superFooterContainerContainer = TGLinearLayout(.vert)
        superFooterContainerContainer.tg_height.equal(.wrap)
        superFooterContainerContainer.tg_leading.equal(TGLayoutPos.tg_safeAreaMargin)
        superFooterContainerContainer.tg_bottom.equal(TGLayoutPos.tg_safeAreaMargin)
        superFooterContainerContainer.tg_trailing.equal(TGLayoutPos.tg_safeAreaMargin)
        superFooterContainerContainer.backgroundColor = .clear
        
        superFooterContainer.addSubview(superFooterContainerContainer)
        rootContainer.addSubview(superFooterContainer)
    }
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 关闭界面
    func finish() {
        navigationController?.popViewController(animated: true)
    }
    
    func bindData() {
        
    }
    
    func tableViewAddEmptyView() {
        let emptyV:HDEmptyView = HDEmptyView.emptyActionViewWithImageStr(imageStr: "custom_blank_icon", titleStr: "空空如也".localized() as NSString, detailStr: "", btnTitleStr: "", target: self, action: #selector(reloadBtnAction)) as! HDEmptyView
        
        emptyV.titleLabTextColor = UIColor.red
        emptyV.actionBtnFont = UIFont.systemFont(ofSize: 19)
        emptyV.contentViewY = -90
        emptyV.actionBtnIsHidden = true
        emptyV.titleLabFont = UIFont(name: "PingFangSC-Medium", size: 16)!
        emptyV.titleLabTextColor =  UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        tableView.ly_emptyView = emptyV
    }
    
    func isNeedEmptyView() {
        view.addSubview(emptyView)
        isHaveEmpty = true
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(tableView)
            make.left.equalTo(tableView)
            make.right.equalTo(tableView)
            make.bottom.equalTo(tableView)
        }
    }
    
}


extension BaseLogicController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isHaveEmpty {
            if datum.count > 0 {
                emptyView.hide()
            } else {
                emptyView.show()
            }
        }
 
        return datum.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    @objc override func reloadBtnAction() {
        print("点击刷新按钮")
    }
    
}
