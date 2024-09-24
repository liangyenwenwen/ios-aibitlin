//
//  CategoriesBottomView.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation
import UIKit

private let MinCellSize = CGFloat(35)

internal protocol CategoriesTabViewDelegate: AnyObject {
    
    func categoriesBottomViewDidSelecteCategory(_ category: TabCategory, bottomView: CategoriesTabView)
}

final internal class CategoriesTabView: UIView {
    
    // MARK: - Internal variables
    
    internal weak var delegate: CategoriesTabViewDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var emojiTabButton: UIButton! {
        didSet {
            let normalImage = UIImage(named: "ic_emoji_tab_normal", in: Bundle.podBundle,compatibleWith: nil)
            let selectedImage = UIImage(named: "ic_emoji_tab_select", in: Bundle.podBundle,compatibleWith: nil)
            emojiTabButton.setImage(normalImage, for: .normal)
            emojiTabButton.setImage(selectedImage, for: .selected)
            emojiTabButton.isSelected = true
        }
    }
    
    @IBOutlet private weak var favoriteTabButton: UIButton! {
        didSet {
            let normalImage = UIImage(named: "ic_favorite_tab_normal", in: Bundle.podBundle,compatibleWith: nil)
            let selectedImage = UIImage(named: "ic_favorite_tab_select", in: Bundle.podBundle,compatibleWith: nil)
            favoriteTabButton.setImage(normalImage, for: .normal)
            favoriteTabButton.setImage(selectedImage, for: .selected)
        }
    }

    // MARK: - Init functions
    
    static internal func loadFromNib() -> CategoriesTabView {
        let nibName = String(describing: CategoriesTabView.self)
        
        guard let nib = Bundle.podBundle.loadNibNamed(nibName, owner: nil, options: nil) as? [CategoriesTabView] else {
            fatalError()
        }
        
        guard let bottomView = nib.first else {
            fatalError()
        }
        
        
        return bottomView
    }
    
    // MARK: - Override functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    // MARK: - IBActions
    
    @IBAction private func emojiTabAction() {
        emojiTabButton.isSelected = true
        favoriteTabButton.isSelected = false
        delegate?.categoriesBottomViewDidSelecteCategory(.emoji, bottomView: self)
    }
    
    @IBAction private func favoriteTabAction() {
        favoriteTabButton.isSelected = true
        emojiTabButton.isSelected = false
        delegate?.categoriesBottomViewDidSelecteCategory(.favorite, bottomView: self)
    }
    
}
