//
//  ConversationItem.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

class ConversationItem {
    
    let conversation: Conversation
    let currentUsername: String
    
    init(conversation: Conversation, currentUsername: String) {
        self.conversation = conversation
        self.currentUsername = currentUsername
    }
}
