//
//  SendMessageRequest.swift
//  iZalo
//
//  Created by CPU11613 on 10/1/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

struct SendMessageRequest {
    
    public let message: Message
    public let conversation: Conversation
    
    func messageToDictionary() -> [String: Any] {
        return [
            "id": self.message.id,
            "senderId": self.message.senderId,
            "conversationId": self.message.conversationId,
            "content": self.message.content,
            "type": self.message.type,
            "timestamp": self.message.timestamp,
            "timestampInString": self.message.timestampInString
        ]
    }
    
    func conversationToDictionary() -> [String: Any] {
        return [
            "id": self.conversation.id,
            "name": self.conversation.name,
            "lastMessage": self.messageToDictionary(),
            "members": self.stringArrayToDictionary(array: self.conversation.members)
        ]
    }
    func stringArrayToDictionary(array: [String]) -> [String: Any] {
        var returnDictionary: [String: Any] = [:]
        for element in array {
            returnDictionary[element] = element
        }
        return returnDictionary
    }
}
