//
//  BaseCollectionViewCell.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/27.
//

import UIKit
import TangramKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    var container:TGBaseLayout!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func innerInit() {
        initViews()
        initDatum()
        initListeners()
    }
    
    func initViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        container = TGLinearLayout(getContainerOrientation())
        container.tg_width.equal(.fill)
        container.tg_height.equal(.wrap)
        container.tg_space = PADDING_MEDDLE
        contentView.addSubview(container)
        
    }
    
    func initDatum()  {
        
    }
    
    func initListeners() {
        
    }
    
    func getContainerOrientation() -> TGOrientation {
        return .vert
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return self.container.systemLayoutSizeFitting(targetSize)
    }

}
