//
//  EmojiCategory.swift
//  ISEmojiView
//
//  Created by Beniamin Sarkisyan on 01/08/2018.
//

import Foundation

public class EmojiCategory {
    
    // MARK: - Public variables
    
    public var category: Category!
    public var emojis: [Emoji]!
    public var faceEmoji: [FaceEmoji]!
    
    // MARK: - Initial functions
    
    public init(category: Category, emojis: [Emoji] = [], faceEmoji: [FaceEmoji] = []) {
        self.category = category
        self.emojis = emojis
        self.faceEmoji = faceEmoji
    }
}
