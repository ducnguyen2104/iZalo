//
//  LoginRequest.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

struct LoginRequest {
    
    let username: String
    let password: String
    
    func toDictionary() -> [String: Any] {
        return [
            "username": self.username,
            "password": self.password
        ]
    }
}
