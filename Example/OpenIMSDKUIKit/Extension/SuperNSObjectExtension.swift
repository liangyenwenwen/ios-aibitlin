//
//  SuperNSObjectExtension.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/27.
//

import Foundation

extension NSObject {
    
    static var className: String {
        return String(describing: Self.self)
    }
    
   
}
