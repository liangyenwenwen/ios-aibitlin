//
//  ViewFactoryUtil.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/24.
//

import Foundation
import UIKit
import TangramKit

class ViewFactoryUtil {
    
    static var titleLblSelf = UILabel()
    
    static func tableView(_ style: UITableView.Style = .plain) -> UITableView {
//        let r = QMUITableView()
        let r = QMUITableView(frame: .zero, style: style)
        r.backgroundColor = .clear
        r.tableFooterView = UIView()
        r.separatorStyle = .none
        r.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        
        //自适应高度
        r.rowHeight = UITableView.automaticDimension
        r.estimatedRowHeight = UITableView.automaticDimension
        
        r.showsVerticalScrollIndicator = false
        
        r.allowsSelection = true
        
        return r
    }
    
    static func collectionView() -> UICollectionView {
        
        let r = UICollectionView(frame: .zero, collectionViewLayout:collectionViewFlowLayout())
        r.backgroundColor = .clear
        r.showsHorizontalScrollIndicator = false
        r.showsVerticalScrollIndicator = false
        
        r.contentInsetAdjustmentBehavior = .never
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        
        return r
    }
    
    static func collectionViewFlowLayout() -> UICollectionViewFlowLayout {
        let r = UICollectionViewFlowLayout()
        r.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        r.scrollDirection = .vertical
        
        r.minimumLineSpacing = 0
        r.minimumInteritemSpacing = 0
        
        return r
    }
    
    
   
    
    ///水平 分割线
    static func smallDivider() -> UIView {
        let r = UIView()
        r.tg_width.equal(.fill)
        r.tg_height.equal(0.5)
        r.tg_left.equal(20)
        r.backgroundColor = .colorDivider
        return r
    }
    
    static func smallDivider(space: CGFloat = 20) -> UIView {
        let r = UIView()
        r.tg_width.equal(.fill)
        r.tg_height.equal(0.5)
        r.tg_left.equal(space)
        r.tg_right.equal(space)
        r.backgroundColor = .colorDivider
        return r
    }
    
    ///水平 分割线
    static func normalTextView(_ placeholder: String = "PleaseFillIn".localized()) -> QMUITextView {
        let r = QMUITextView()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        r.placeholder = placeholder
        r.placeholderColor = .placeholder
        
        return r
    }
    
}

// MARK: -  Label
extension ViewFactoryUtil  {
    ///普通的包裹Label
    static func normalLbael(_ title: String = "测试1111") -> QMUILabel {
        let r = QMUILabel()
        r.text = title
        r.textColor = .colorOnSurface
        r.font = .systemFont(ofSize: 14)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        return r
    }
    
    ///小文字tilte
    static func sectionTilteLbael(_ title: String = "测试",  top: CGFloat = 0) -> UILabel {
        let r = normalLbael()
        r.textColor = .black666
        r.tg_width.equal(.fill)
        r.tg_top.equal(top)
        r.font = .mediumFont(14)
        r.text = title
        return r
    }
    
    ///自定义lable
    static func customTilteLabelFill(_ title: String, font: CGFloat, textColor: UIColor = .colorOnBackground) -> UILabel {
        let r = normalLbael()
        r.textColor = textColor
        r.tg_width.equal(.fill)
        r.font = .systemFont(ofSize: font)
        r.text = title
        return r
    }
    
    ///自定义lable
    static func customTilteLableWrap(_ title: String, font: CGFloat, textColor: UIColor = .colorOnBackground) -> UILabel {
        let r = normalLbael()
        r.textColor = textColor
        r.font = .systemFont(ofSize: font)
        r.text = title
        return r
    }
    
    /// 加粗lable fill
    static func customBoldTilteLable(_ title: String, font: CGFloat = TEXT_LARGE, textColor: UIColor = .colorOnSurface) -> UILabel {
        let r = normalLbael()
        r.textColor = textColor
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.font = UIFont(name: "PingFangSC-Medium", size: font)
        r.text = title
        titleLblSelf = r
        return r
    }
    
}

// MARK: -  按钮
extension ViewFactoryUtil {
    // 主色调小圆角button
    static func primaryButton() -> QMUIButton {
        let r = QMUIButton()
        r.adjustsTitleTintColorAutomatically = false
        r.adjustsButtonWhenHighlighted = true
        r.titleLabel?.font = .systemFont(ofSize: TEXT_MEDDLE)
        r.tg_width.equal(.fill)
        r.tg_height.equal(BUTTON_MEDDLE)
        r.backgroundColor = .colorPrimary
        r.layer.cornerRadius = SMALL_RADIUS
        r.tintColor = .colorLightWhite
        r.setTitleColor(.colorLightWhite, for: .normal)
        return r
    }
    
    
    /// 主色调半圆角按钮
    static func primaryHalfFilletButton() -> QMUIButton{
        let r = primaryButton()
        r.layer.cornerRadius = BUTTON_MEDDLE_RADIUS
        return r
    }
    
    /// 创建只有标题的按钮 类似网页链接
    static func linkButton(_ title: String = "") -> QMUIButton {
        let r = QMUIButton()
        r.setTitle(title, for: .normal)
        r.adjustsTitleTintColorAutomatically = false
        r.titleLabel?.font = .systemFont(ofSize: TEXT_MEDDLE)
        r.sizeToFit()
        return r
    }
    
    /// 空心按钮
    static func primaryOutlineButton() -> QMUIButton {
        let r = primaryButton()
        r.backgroundColor = .clear
        r.layer.borderColor = UIColor.primaryColor.cgColor
        r.layer.borderWidth = 1
        r.tintColor = .black130
        r.setTitleColor(.primaryColor, for: .normal)
        r.titleLabel?.font = .systemFont(ofSize: TEXT_MEDDLE)
        return r
    }
    
    ///次要半圆角按钮
    static func secondhalfFilletSamllButton() -> QMUIButton {
        let r = QMUIButton()
        r.adjustsTitleTintColorAutomatically = false
        r.adjustsButtonWhenHighlighted = true
        r.titleLabel?.font = .systemFont(ofSize: TEXT_MEDDLE)
        r.tg_width.equal(90)
        r.tg_height.equal(BUTTON_SMALL)
        r.border(.black80)
        r.corner(BUTTON_SMALL_RADIUS)
        r.tintColor = .black80
        r.setTitleColor(.black80, for: .normal)
        return r
    }
    
    ///默认30宽高的按钮button
    static func imageBtn(_ image: UIImage, _ imageSize: CGFloat = 30) -> QMUIButton {
        let r = QMUIButton()
        r.adjustsTitleTintColorAutomatically = false
        r.tg_width.equal(imageSize)
        r.tg_height.equal(imageSize)
        r.tintColor = .colorOnSurface
        r.setImage(image, for: .normal)
        return r
    }
    
    
    /// 创建次要，半圆角，小按钮
    static func secondHalfFilletSmallButton() -> QMUIButton {
        let result = QMUIButton()
        result.titleLabel?.font = UIFont.systemFont(ofSize: TEXT_MEDDLE)
        result.tg_width.equal(90)
        result.tg_height.equal(BUTTON_SMALL)
        result.tintColor = .black80
        result.layer.cornerRadius = BUTTON_SMALL_RADIUS
        result.layer.borderWidth = 1
        result.layer.borderColor = UIColor.black80.cgColor
        result.setTitleColor(.black80, for: .normal)
        return result
    }
    
    static func button(title:String,color:UIColor) -> QMUIButton {
        let result = QMUIButton()
        result.adjustsTitleTintColorAutomatically = false
        result.tg_width.equal(.fill)
        result.tg_height.equal(BUTTON_MEDDLE)
        result.titleLabel?.font = UIFont.systemFont(ofSize: TEXT_LARGE3)
        result.setTitle(title, for: .normal)
        result.setTitleColor(color, for: .normal)
        result.backgroundColor = .colorBackgroundAPP
        
        //按下高亮时的背景色
        result.highlightedBackgroundColor = .colorSurfaceClick
        return result
    }
    
    
    static func lblViewButton(title: String, _ height: CGFloat = 28) -> TGLinearLayout {
        let  r = TGLinearLayout(.horz)
        r.backgroundColor = .init(hexString: "#388CEF")
        r.tg_width.equal(.wrap)
        r.tg_height.equal(height)
        r.corner(height / 2)
        r.tg_padding = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: 11)
        r.tg_gravity = .vert.center
        
        let lbl = UILabel()
        r.addSubview(lbl)
        lbl.textColor = .white
        lbl.font = .regularFont(14)
        lbl.text = title
        lbl.tg_width.equal(.wrap)
        lbl.tg_height.equal(.wrap)
        lbl.tag = 20002

        return r
    }
    

    
    
}

// MARK: - 图片
extension ViewFactoryUtil {
    
    static func moreIconView() -> UIImageView {
        let r = UIImageView()
        r.tg_width.equal(15)
        r.tg_height.equal(15)
        r.image = R.image.superChevronRight()?.withTintColor()
        r.tintColor = .black80
        r.tg_centerY.equal(0)
        r.contentMode = .scaleAspectFit
        return r
    }
    
    static func defalutImgView(_ data: UIImage, _ size: CGFloat = 50.0) -> UIImageView {
        let r = UIImageView()
        r.image = data
        r.tg_width.equal(size)
        r.tg_height.equal(size)
        r.contentMode = .scaleAspectFit
        return r
    }
    
    static func cornerImgView(_ data: UIImage, _ size: CGFloat = 50.0, _ corner: CGFloat = 8) -> UIImageView {
        let r = defalutImgView(data, size)
        r.corner(corner)
        r.contentMode = .scaleAspectFit
        return r
    }
    
    
    static func circleImgView(_ data: UIImage, _ size: CGFloat = 50.0 ) -> UIImageView {
        let r = defalutImgView(data, size)
        r.corner(size / 2)
        r.contentMode = .scaleAspectFit
        return r
    }
    
}

// MARK: - 常用组件
extension ViewFactoryUtil {
    
    /// 留白视图 高度
    static func blankView(_ height:CGFloat = 10) -> UIView {
        let blankView = TGLinearLayout(.vert)
        blankView.tg_width.equal(.fill)
        blankView.tg_height.equal(height)

        return blankView
    }
    
    /// lineView
    static func vertLineView(_ height:CGFloat = 20, _ color: UIColor = .colorOnBackground) -> UIView {
        let blankView = TGLinearLayout(.vert)
        blankView.tg_width.equal(1)
        blankView.tg_height.equal(height)
        blankView.backgroundColor = color
        return blankView
    }
    
    
    ///  分组 头部
    static func sectionHeaderView(_ image: UIImage = R.image.boke_icon()!,  title: String = "标题", isHaveMore: Bool = false) -> UIView{
        let sectionHaderView = TGLinearLayout(.horz)
        sectionHaderView.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        sectionHaderView.tg_width.equal(.fill)
        sectionHaderView.tg_height.equal(.wrap)
        sectionHaderView.tg_space = PADDING_MEDDLE
        
        let leftImg = ViewFactoryUtil.defalutImgView(image, 20)
        leftImg.tg_centerY.equal(0)
        leftImg.tag = 20003
        sectionHaderView.addSubview(leftImg)
        
        let titleLbl = ViewFactoryUtil.customBoldTilteLable(title)
        titleLblSelf = titleLbl
        titleLbl.tg_centerY.equal(0)
        titleLbl.tg_width.equal(.fill)
        sectionHaderView.addSubview(titleLbl)
        titleLbl.tag = 20001
        titleLbl.numberOfLines = 1
        
        if(isHaveMore) {
            let moreImg = ViewFactoryUtil.moreIconView()
            sectionHaderView.addSubview(moreImg)
        }
        
        return sectionHaderView
    }
    
    ///  分组 头部
    static func sectionHeaderViewAboutVIP(_ image: UIImage = R.image.boke_icon()!,  title: String = "标题", isHaveMore: Bool = false) -> UIView{
        let sectionHaderView = TGLinearLayout(.horz)
        sectionHaderView.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        sectionHaderView.tg_width.equal(.fill)
        sectionHaderView.tg_height.equal(.wrap)
        sectionHaderView.tg_space = PADDING_MEDDLE
        
        let leftImg = ViewFactoryUtil.defalutImgView(image, 20)
        leftImg.tg_centerY.equal(0)
        sectionHaderView.addSubview(leftImg)
        
        let titleLbl = ViewFactoryUtil.customBoldTilteLable(title)
        titleLblSelf = titleLbl
        titleLbl.tg_centerY.equal(0)
        titleLbl.tg_width.equal(.wrap)
        sectionHaderView.addSubview(titleLbl)
        titleLbl.tag = 20001
        titleLbl.numberOfLines = 1
        
        
        let copyImg = ViewFactoryUtil.defalutImgView(R.image.copy_icon()!, 16)
        copyImg.tg_centerY.equal(0)
        copyImg.tg_left.equal(-10)
        sectionHaderView.addSubview(copyImg)
        copyImg.tag = 20002
        
        let view = UIView()
        titleLbl.tg_centerY.equal(0)
        view.tg_width.equal(.fill)
        sectionHaderView.addSubview(view)
        
        if(isHaveMore) {
            let moreImg = ViewFactoryUtil.moreIconView()
            sectionHaderView.addSubview(moreImg)
        }
        
        return sectionHaderView
    }
    
    
    
    
    
}
