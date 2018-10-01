//
//  MessageRealm.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RealmSwift

class MessageRealm: Object {
    @objc dynamic var id: String = "id"
    @objc dynamic var senderId: String = "senderId"
    @objc dynamic var conversationId: String = "conversationId"
    @objc dynamic var content: String = "content"
    @objc dynamic var type: String = "type"
    @objc dynamic var timestamp: Int = 0
    @objc dynamic var timestampInString: String = "timestampInString"

    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(message: Message) -> MessageRealm {
        let messageRealm = MessageRealm()
        messageRealm.id = message.id
        messageRealm.senderId = message.senderId
        messageRealm.conversationId = message.conversationId
        messageRealm.content = message.content
        messageRealm.type = message.type
        messageRealm.timestamp = message.timestamp
        messageRealm.timestampInString = message.timestampInString
        return messageRealm
    }
    
    func convert() -> Message {
        return Message(id: self.id, senderId: self.senderId, conversationId: self.conversationId, content: self.content, type: self.type, timestamp: self.timestamp, timestampInString: self.timestampInString)
    }
}

