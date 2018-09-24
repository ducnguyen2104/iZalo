//
//  ConversationLocalSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol ConversationLocalSource {
    func loadConversation() -> Observable<[Conversation]>
    func persistConversation(conversations: [Conversation]) -> Observable<Bool>
}

class ConversationLocalSourceFactory {
    static let sharedInstance: ConversationLocalSource = ConversationRealmSource()
}
