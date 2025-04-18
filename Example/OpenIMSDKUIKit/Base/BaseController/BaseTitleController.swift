//
//  BaseTitleController.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/28.
//

import UIKit

class BaseTitleController: BaseLogicController {
    override func initLinearLayoutSafeArea() {
        super.initLinearLayoutSafeArea()

        prepareInitNav()
    }

    override func initRelativeLayoutSafeArea() {
        super.initRelativeLayoutSafeArea()
        prepareInitNav()
    }
    override func initRelativeLayoutSafeAreaAboutTab() {
        super.initRelativeLayoutSafeAreaAboutTab()
        prepareInitNav()
    }
    
    func prepareInitNav() {
        if isAddNavView() {
            initNavView()
        }
    }
    
    override var title: String? {
        didSet {
            navView.titleView.text = title
        }
    }

    func isAddNavView() -> Bool {
        return true
    }

    func initNavView() {
        superHeaderContainerContainer.addSubview(navView)
        if navigationController?.viewControllers.count ?? 0 > 1 {
            let r =  addLeftImageButton(R.image.arrowLeft()!.withTintColor())
            if Self.className == "UserMessageVC"{
                r.tintColor = .white
            }
            r.tag = 1100
            print(Self.className)
        }
    }

    lazy var navView: BaseNavView = {
        let r = BaseNavView()
        return r
    }()
    
    
    @discardableResult
    func addLeftImageButton(_ data:UIImage) -> QMUIButton {
        let r = ViewFactoryUtil.imageBtn(data)
        r.addTarget(self, action: #selector(leftBtnClick(_:)), for: .touchUpInside)
        navView.addLeftItem(r)
        return r
    }
    
    @objc func leftBtnClick(_ sender: QMUIButton) {
        if sender.tag == 1100 {
            navigationController?.popViewController(animated: true)
           
        }
    }
    
    func addRightImageButton(_ data:UIImage)  {
        let r = ViewFactoryUtil.imageBtn(data)
        r.addTarget(self, action: #selector(rightBtnClick(_:)), for: .touchUpInside)
        navView.addRighttItem(r)
    }
    

    func addRightTextButton(_ data:String, color: UIColor = .colorOnSurface)  {
        let r = ViewFactoryUtil.linkButton()
        r.addTarget(self, action: #selector(rightBtnClick(_:)), for: .touchUpInside)
        r.setTitle(data, for: .normal)
        r.setTitleColor(color, for: .normal)
        r.sizeToFit()
        navView.addRighttItem(r)
    }
    
    @objc func rightBtnClick(_ sender: QMUIButton) {
        print(#function, #line)
    }
    
    
    func addNavCenterItem(_ data:UIView)  {

        navView.addCenterItem(data)
    }
}

