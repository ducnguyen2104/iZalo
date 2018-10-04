//
//  ConversationRepository.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol ConversationRepository {
    func loadConversation(username: String) -> Observable<[Conversation]>
}

class ConversationRepositoryFactory {
    public static let sharedInstance: ConversationRepository = ConversationRepositoryImpl(remoteSource: ConversationRemoteSourceFactory.sharedInstance, localSource: ConversationLocalSourceFactory.sharedInstance, userRepository: UserRepositoryFactory.sharedInstance)
}
