//
//  EmojiItem.swift
//  iZalo
//
//  Created by CPU11613 on 10/18/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxDataSources

class EmojiItem {
    let emoji: String
    
    init(emoji: String) {
        self.emoji = emoji
    }
}

extension EmojiItem: IdentifiableType {
    var identity: String {
        return self.emoji
    }
}

extension EmojiItem: Equatable {
    static func == (lhs: EmojiItem, rhs: EmojiItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
