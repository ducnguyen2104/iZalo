//
//  MessageClassifier.swift
//  iZalo
//
//  Created by CPU11613 on 9/27/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

class MessageClassifier {
    static let userRepository = UserRepositoryFactory.sharedInstance
    class func isMine(message: Message) -> Bool {
        userRepository.loadUser().take(1)
        return true
    }
}
