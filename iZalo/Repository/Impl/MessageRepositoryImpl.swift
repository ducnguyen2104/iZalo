//
//  MessageRepositoryImpl.swift
//  iZalo
//
//  Created by CPU11613 on 10/1/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class MessageRepositoryImpl: MessageRepository {
    
    private let remoteSource: MessageRemoteSource
    private let localSource: MessageLocalSource
    private let userRepository: UserRepository
    
    init(remoteSource: MessageRemoteSource,
         localSource: MessageLocalSource,
         userRepository: UserRepository) {
        self.remoteSource = remoteSource
        self.localSource = localSource
        self.userRepository = userRepository
    }
    
    func loadMessage(conversation: Conversation) -> Observable<[Message]> {
        return Observable.deferred{
            return self.userRepository
            .loadUser()
            .take(1)
            .flatMap{ (user) -> Observable<[Message]> in
                guard let user = user else {
                    return Observable.error(AuthenticateError(errorMessage: ""))
                }
                
                return self.remoteSource
                    .getMessage(conversation: conversation, user: user)
                
            }
        }
    }

    func sendMessage(request: SendMessageRequest) -> Observable<Bool> {
        return remoteSource.sendMessage(request: request)
    }
}
