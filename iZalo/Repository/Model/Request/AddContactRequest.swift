//
//  AddFriendRequest.swift
//  iZalo
//
//  Created by CPU11613 on 10/11/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

struct AddContactRequest {
    
    let currentUsername: String
    let targetUsername: String
    
    func toDictionary() -> [String: Any] {
        return [
            "currentUsername": self.currentUsername,
            "targetUsername": self.targetUsername
        ]
    }
}
