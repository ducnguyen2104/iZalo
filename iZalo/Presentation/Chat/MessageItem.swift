//
//  MessageItem.swift
//  iZalo
//
//  Created by CPU11613 on 9/27/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxDataSources

class MessageItem {
    
    let message: Message
    let currentUsername: String
    
    init(message: Message, currentUsername: String) {
        self.message = message
        self.currentUsername = currentUsername
    }
}

extension MessageItem: IdentifiableType {
    var identity: String {
        return self.message.id
    }
}

extension MessageItem: Equatable {
    static func == (lhs: MessageItem, rhs: MessageItem) -> Bool {
            return lhs.identity == rhs.identity
    }
}
