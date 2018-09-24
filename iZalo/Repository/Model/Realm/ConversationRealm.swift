//
//  ConversationRealm.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RealmSwift

class ConversationRealm: Object {
    @objc dynamic var id: String = "id"
    @objc dynamic var name: String = "name"
    let members = List<String>()
    var lastMessage = MessageRealm()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(conversation: Conversation) -> ConversationRealm {
        let conversationRealm = ConversationRealm()
        conversationRealm.id = conversation.id
        conversationRealm.name = conversation.name
        for member in conversation.members {
            conversationRealm.members.append(member)
        }
        conversationRealm.lastMessage = MessageRealm.from(message: conversation.lastMessage)
        return conversationRealm
    }
    
    func convert() -> Conversation {
        return Conversation(id: self.id, name: self.name, members: Array(self.members), lastMessage: lastMessage.convert())
    }
}
