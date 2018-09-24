//
//  ConversationResponse.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

class ConversationResponse {
    let id: String
    let name: String
    let members: NSDictionary
    let lastMessage: MessageResponse
    
    required init(value: NSDictionary) {
        self.id = value.value(forKey: "id") as! String
        self.name = value.value(forKey: "name") as! String
        self.members = value.value(forKey: "members") as! NSDictionary
        self.lastMessage = MessageResponse(value: value.value(forKey: "lastMessage") as! NSDictionary)
        print("conversation: \(self.id)")
    }
    
    func convert() -> Conversation {
        return Conversation(id: self.id, name: self.name, members: self.members.allValues as! [String], lastMessage: self.lastMessage.convert())
    }
}
