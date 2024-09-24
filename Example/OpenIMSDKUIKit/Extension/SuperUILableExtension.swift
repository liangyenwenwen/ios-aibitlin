//
//  SuperUILableExtension.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import Foundation

extension UILabel {
    
    
    /// 设置行间距
    /// - Parameter space: 行间距
    func lineSpace(_ space: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing  = space - (self.font.lineHeight - self.font.pointSize);
        
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
        ]
        let attributedString = NSAttributedString(string: self.text ?? "", attributes: attributes)
        self.attributedText = attributedString
    }
    
    
    /// 给Lbl某段字符串改变颜色
    /// - Parameters:
    ///   - changeColorStr: 需要改变的字符串
    ///   - changeColor: 改变后的颜色
    func changeColor(changeColorStr: String, changeColor:UIColor = .red) {
        let range = self.text?.range(of: changeColorStr)
        let attributedString = NSMutableAttributedString(string: self.text!)
        attributedString.addAttribute(.foregroundColor, value: changeColor, range: (self.text?.nsRange(from: range!))!)
        self.attributedText = attributedString
    }
}

