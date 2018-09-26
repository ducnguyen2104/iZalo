//
//  User.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

struct User {
    let username: String
    let password: String
    let name: String
    let phone: String
    let avatarURL: String?
    let conversations: [String]
    let contacts: [String]
}
