//
//  UIView+Extension.swift
//  OUIIM
//
//  Created by mac on 2024/9/3.
//

import Foundation

extension UIView {
    
   public func setCorners(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        let path = UIBezierPath()
     
        // 左上角
        path.move(to: CGPoint(x: topLeft, y: 0))
        path.addLine(to: CGPoint(x: 0, y: topLeft))
        path.addLine(to: CGPoint(x: topLeft, y: 0))
        
        // 右上角
        path.move(to: CGPoint(x: self.bounds.width - topRight, y: 0))
        path.addLine(to: CGPoint(x: self.bounds.width, y: topRight))
        path.addLine(to: CGPoint(x: self.bounds.width - topRight, y: 0))
        
        // 左下角
        path.move(to: CGPoint(x: 0, y: self.bounds.height - bottomLeft))
        path.addLine(to: CGPoint(x: bottomLeft, y: self.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: self.bounds.height - bottomLeft))
        
        // 右下角
        path.move(to: CGPoint(x: self.bounds.width, y: self.bounds.height - bottomRight))
        path.addLine(to: CGPoint(x: self.bounds.width - bottomRight, y: self.bounds.height))
        path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - bottomRight))
        
        path.close()
     
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

}
