//
//  ConversationResponse.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class ConversationResponse {
    
    let id: String
    let name: String
    let members: NSDictionary
    let lastMessage: MessageResponse
    private let contactRepo = ContactRepositoryFactory.sharedInstance
    
    required init(value: NSDictionary) {
        self.id = value.value(forKey: "id") as! String
        self.name = value.value(forKey: "name") as! String
        self.members = value.value(forKey: "members") as! NSDictionary
        self.lastMessage = MessageResponse(value: value.value(forKey: "lastMessage") as! NSDictionary)
    }
    
    //    func convert(currentUsername: String) -> Observable<Conversation> {
    //        return contactRepo.getAvatarURL(username: currentUsername).flatMap{ [unowned self] (avatarURL) -> Observable<Conversation> in
    //            switch self.members.count {
    //            case 2:
    //                if (self.members.allValues[0] as! String == currentUsername) {
    //                                    return Observable.just(Conversation(id: self.id, name: self.members.allValues[1] as! String, members: self.members.allValues as! [String], lastMessage: self.lastMessage.convert()))
    //                                } else {
    //                                    return Observable.just(Conversation(id: self.id, name: self.members.allValues[0] as! String, members: self.members.allValues as! [String], lastMessage: self.lastMessage.convert()))
    //                                }
    //            default:
    //                return Observable.just(Conversation(id: self.id, name: self.name, members: self.members.allValues as! [String], lastMessage: self.lastMessage.convert()))
    //            }
    //        }
    //    }
    
    func convert(currentUsername: String) -> Conversation {
        switch self.members.count {
        case 2:
            if (self.members.allValues[0] as! String == currentUsername) {
                return (Conversation(id: self.id, name: self.members.allValues[1] as! String, members: self.members.allValues as! [String], lastMessage: self.lastMessage.convert()))
            } else {
                return (Conversation(id: self.id, name: self.members.allValues[0] as! String, members: self.members.allValues as! [String], lastMessage: self.lastMessage.convert()))
            }
        default:
            return (Conversation(id: self.id, name: self.name, members: self.members.allValues as! [String], lastMessage: self.lastMessage.convert()))
        }
        
    }
}
