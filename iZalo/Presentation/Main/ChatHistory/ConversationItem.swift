//
//  ConversationItem.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class ConversationItem {
    
    let conversation: Conversation
    let currentUsername: String
    private let contactRepository = ContactRepositoryFactory.sharedInstance
    let contactObservable: Observable<Contact>
    init(conversation: Conversation, currentUsername: String) {
        self.conversation = conversation
        self.currentUsername = currentUsername
        self.contactObservable = self.contactRepository.getContactInfo(username: self.conversation.members[1] != self.currentUsername ? self.conversation.members[1] : self.conversation.members[0])
    }
}
