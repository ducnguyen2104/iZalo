//
//  ConversationRepositoryImpl.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class ConversationRepositoryImpl: ConversationRepository {
    private let remoteSource: ConversationRemoteSource
    private let localSource: ConversationLocalSource
    private let userRepository: UserRepository
    
    init(remoteSource: ConversationRemoteSource,
         localSource: ConversationLocalSource,
         userRepository: UserRepository) {
        self.remoteSource = remoteSource
        self.localSource = localSource
        self.userRepository = userRepository
    }
    
    func loadConversation() -> Observable<[Conversation]> {
        print("ConversationRepositoryImpl loadConversation")
        return Observable.deferred {
            return self.userRepository
                .loadUser()
                .take(1)
                .flatMap { (user) -> Observable<[Conversation]> in
                    guard let user = user else {
                        return Observable.error(AuthenticateError(errorMessage: ""))
                    }
                    
                    return self.remoteSource
                        .getConversation(user: user)
                        .flatMap { [unowned self] (conversations) -> Observable<[Conversation]> in
                            return self.localSource
                                .persistConversation(conversations: conversations)
                                .map { (_) in conversations }
                    }
                }
                .catchError { (error) in
                    if let networkError = error as? NetworkError {
                        if networkError.errorType == .NoInternetConnection {
                            return self.localSource
                                .loadConversation()
                        } else if networkError.errorType == .ClientError && networkError.errorCode == 401 {
                            return Observable.error(AuthenticateError(errorMessage: ""))
                        }
                    }
                    
                    return Observable.error(error)
            }
        }
    }
}
