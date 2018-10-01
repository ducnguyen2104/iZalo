//
//  MessageItem.swift
//  iZalo
//
//  Created by CPU11613 on 9/27/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

class MessageItem {
    
    let message: Message
    let currentUsername: String
    
    init(message: Message, currentUsername: String) {
        self.message = message
        self.currentUsername = currentUsername
    }
}
