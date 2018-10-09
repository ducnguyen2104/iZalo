//
//  SignUpRequest.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

struct SignupRequest {
    
    let username: String
    let password: String
    let name: String
    let phone: String
    
    func makeUser() -> User {
        return User(username: self.username, password: self.password, name: self.name, phone: self.phone, avatarURL: Constant.defaultAvatarURL, conversations: [], contacts: [])
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "username": self.username,
            "password": self.password,
            "name": self.name,
            "phone": self.phone
        ]
    }
}
