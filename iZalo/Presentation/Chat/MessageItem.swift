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
    let isTimeHidden: Bool
    let isAvatarHidden: Bool
    
    init(message: Message, currentUsername: String, isTimeHidden: Bool, isAvatarHidden: Bool) {
        self.message = message
        self.currentUsername = currentUsername
        self.isTimeHidden = isTimeHidden
        self.isAvatarHidden = isAvatarHidden
    }
}

extension MessageItem: IdentifiableType {
    var identity: String {
        return self.message.id
    }
}

extension MessageItem: Equatable {
    static func == (lhs: MessageItem, rhs: MessageItem) -> Bool {
        if lhs.message.type == Constant.fileMessage
        || rhs.message.type == Constant.imageMessage {
            return lhs.identity == rhs.identity
                && lhs.message.content == rhs.message.content
                && lhs.isTimeHidden == rhs.isTimeHidden
                && lhs.isAvatarHidden == rhs.isAvatarHidden
        }
            return lhs.identity == rhs.identity
                && lhs.isTimeHidden == rhs.isTimeHidden
                && lhs.isAvatarHidden == rhs.isAvatarHidden
    }
}
