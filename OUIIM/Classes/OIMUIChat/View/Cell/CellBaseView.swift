//
//  CellBaseView.swift
//  Alamofire
//
//  Created by x on 2023/11/28.
//

import Foundation
import OUICore

class CellBaseView: UIView {
    
    
    lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textColor = .black
        v.font = .f12
        v.translatesAutoresizingMaskIntoConstraints = false
        v.setContentCompressionResistancePriority(UILayoutPriority(999), for: .vertical)
        
        return v
    }()
    
    lazy var contentStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [titleLabel])
        v.axis = .vertical
        v.spacing = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutMargins = .zero
        translatesAutoresizingMaskIntoConstraints = false
        insetsLayoutMarginsFromSafeArea = false
        
        addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    internal var viewPortWidth: CGFloat = 300
}
