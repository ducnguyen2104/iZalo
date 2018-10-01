//
//  MessageResponse.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

class MessageResponse {
    let id: String
    let senderId: String
    let conversationId: String
    let content: String
    let type: String
    let timestamp: Int
    let timestampInString: String
    
    required init(value: NSDictionary) {
        self.id = value.value(forKey: "id") as! String
        self.senderId = value.value(forKey: "senderId") as! String
        self.conversationId = value.value(forKey: "conversationId") as! String
        self.content = value.value(forKey: "content") as! String
        self.type = value.value(forKey: "type") as! String
        self.timestamp = value.value(forKey: "timestamp") as? Int ?? -69
        self.timestampInString = value.value(forKey: "timestampInString") as! String
    }
    
    func convert() -> Message {
        return Message(id: self.id, senderId: self.senderId, conversationId: self.conversationId, content: self.content, type: self.type, timestamp: self.timestamp, timestampInString: self.timestampInString)
    }
}
