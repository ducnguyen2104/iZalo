//
//  UserResponse.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import ObjectMapper

class UserResponse {
    
    let username: String
    let password: String
    let name: String
    let phone: String
    let avatarURL: String?
    let conversations: NSDictionary
    let contacts: NSDictionary

    required init(value: NSDictionary) {
        self.username = value.value(forKey: "username") as! String
        self.password = value.value(forKey: "password") as! String
        self.name = value.value(forKey: "name") as! String
        self.phone = String(describing: value.value(forKey: "phone"))
        self.avatarURL = value.value(forKey: "avatarURL") as? String
        self.conversations = value.value(forKey: "conversations") as? NSDictionary ?? NSDictionary()
        self.contacts = value.value(forKey: "contacts") as? NSDictionary ?? NSDictionary()
    }
    
    func convert() -> User {
        return User(username: self.username, password: self.password, name: self.name, phone: self.phone, avatarURL: self.avatarURL, conversations: conversations.allValues as! [String], contacts: contacts.allValues as! [String])
    }
    
    func convertToContact() -> Contact {
        return Contact(username: self.username, name: self.name, phone: self.phone, avatarURL: self.avatarURL ?? Constant.defaultAvatarURL)
    }
}
