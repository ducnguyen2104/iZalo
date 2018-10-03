//
//  LoadConversationRequest.swift
//  iZalo
//
//  Created by CPU11613 on 10/3/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
struct LoadConversationRequest {
    
    let username: String
    
    func toDictionary() -> [String: Any] {
        return [
            "username": self.username
        ]
    }
}
