//
//  ChangeAvatarRequest.swift
//  iZalo
//
//  Created by CPU11613 on 10/15/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

struct ChangeAvatarRequest {
    let currentUsername: String
    let imagePath: URL
    
    func toDictionary() -> [String: Any] {
        return [
            "currentUsername": self.currentUsername,
            "imagePath": self.imagePath
        ]
    }
}
