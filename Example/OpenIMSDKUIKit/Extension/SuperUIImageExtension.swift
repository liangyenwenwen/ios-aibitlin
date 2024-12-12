//
//  SuperUIImageExtension.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/27.
//

import Foundation
import UIKit
 
extension UIImage {
    func withTintColor() -> UIImage {
        let result = self.withRenderingMode(.alwaysTemplate)
        return result
    }
    
    static func getImageAboutColor(color: UIColor) -> UIImage {
        let rect = CGRect.init(x:0, y:0, width:1.0, height:1.0)

        UIGraphicsBeginImageContext(rect.size)

        let context  = UIGraphicsGetCurrentContext()

        context!.setFillColor(color.cgColor)

        context!.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image!
    }
    
    func changeImageColor(color: UIColor) -> UIImage? {
        let templateImage = self.withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(templateImage.size, false, templateImage.scale)
        color.set()
        templateImage.draw(in: CGRect(x: 0, y: 0, width: templateImage.size.width, height: templateImage.size.height))
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return coloredImage
    }

}


