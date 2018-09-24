//
//  ConversationRemoteSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol ConversationRemoteSource {
    func getConversation(user: User) -> Observable<[Conversation]>
}

class ConversationRemoteSourceFactory {
    static let sharedInstance: ConversationRemoteSource = ConversationFirebaseSource()
}
