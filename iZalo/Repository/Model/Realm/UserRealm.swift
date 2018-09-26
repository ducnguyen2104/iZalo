//
//  UserRealm.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RealmSwift

class UserRealm: Object {
    @objc dynamic var username: String = "username"
    @objc dynamic var password: String = "password"
    @objc dynamic var name: String = "name"
    @objc dynamic var phone: String = "phone"
    @objc dynamic var avatarURL: String = "avatarURL"
    let conversations = List<String>()
    let contacts = List<String>()
    
    override static func primaryKey() -> String? {
        return "username"
    }
    
    static func from(user: User) -> UserRealm {
        print("UserRealm persist user: \(user.username)")
        let userRealm = UserRealm()
        userRealm.username = user.username
        userRealm.password = user.password
        userRealm.name = user.name
        userRealm.phone = user.phone
        userRealm.avatarURL = user.avatarURL ?? ""
        for conversation in user.conversations {
            userRealm.conversations.append(conversation)
        }
        for contact in user.contacts {
            userRealm.contacts.append(contact)
        }
        return userRealm
    }
    
    func convert() -> User {
        return User(username: self.username, password: self.password, name: self.name, phone: self.phone, avatarURL: self.avatarURL, conversations: Array(self.conversations), contacts: Array(self.contacts))
    }
}
