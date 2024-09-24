//
//  BaseTableViewCell.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/26.
//

import UIKit
import TangramKit
 
class BaseTableViewCell: UITableViewCell {
    
    //对于需要动态评估高度的cell 需要把布局视图暴漏出去
    var container:TGBaseLayout!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        innerInit()
    }
    
    func innerInit()  {
        initViews()
        initDatum()
        initListeners()
    }
    
    /// 控件
    func initViews()  {
        //背景透明
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        //去掉默认选择颜色
        selectionStyle = .none
        
        //根容器
        container = TGLinearLayout(getContainerOrientation())
        container.tg_width.equal(.fill)
        container.tg_height.equal(.wrap)
        container.tg_space = PADDING_MEDDLE
        contentView.addSubview(container)
    }
    
    /// 设置数据
    func initDatum()  {
        
    }
    
    /// 设置监听器
    func initListeners()  {
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getContainerOrientation() -> TGOrientation {
        return .horz
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return self.container.systemLayoutSizeFitting(targetSize)
    }
}
