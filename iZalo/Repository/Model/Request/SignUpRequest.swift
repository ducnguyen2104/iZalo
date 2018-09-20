//
//  SignUpRequest.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

struct SignUpRequest {
    
    let username: String
    let password: String
    let name: String
    let phone: String
    
    func withPhone(phone: String, phoneCode: String) -> SignUpRequest {
        return SignUpRequest(username: self.username, password: self.password, name: self.name, phone: self.phone)
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
