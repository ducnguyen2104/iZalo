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
    let conversations: NSDictionary

    required init(value: NSDictionary) {
        self.username = value.value(forKey: "username") as! String
        self.password = value.value(forKey: "password") as! String
        self.name = value.value(forKey: "name") as! String
        self.phone = String(describing: value.value(forKey: "phone"))
        self.conversations = value.value(forKey: "conversations") as? NSDictionary ?? NSDictionary()
    }
    
    func convert() -> User {
        return User(username: self.username, password: self.password, name: self.name, phone: self.phone, conversations: conversations.allValues as! [String])
    }
}
