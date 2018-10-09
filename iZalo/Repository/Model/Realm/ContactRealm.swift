//
//  ContactRealm.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RealmSwift

class ContactRealm: Object {
    @objc dynamic var username: String = "username"
    @objc dynamic var name: String = "name"
    @objc dynamic var phone: String = "phone"
    @objc dynamic var avatarURL: String = "avatarURL"
    
    override static func primaryKey() -> String? {
        return "username"
    }
    
    static func from(contact: Contact) -> ContactRealm {
        let contactRealm = ContactRealm()
        contactRealm.username = contact.username
        contactRealm.name = contact.name
        contactRealm.phone = contact.phone
        contactRealm.avatarURL = contact.avatarURL 
        
        return contactRealm
    }
    
    func convert() -> Contact {
        return Contact(username: self.username, name: self.name, phone: self.phone, avatarURL: self.avatarURL)
    }
}
