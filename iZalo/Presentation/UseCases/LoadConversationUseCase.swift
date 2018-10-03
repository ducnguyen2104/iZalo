//
//  LoadConversationUseCase.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class LoadConversationUseCase: UseCase {
    private let repository : ConversationRepository = ConversationRepositoryFactory.sharedInstance
    
    public typealias TRequest = LoadConversationRequest
    public typealias TResponse = [Conversation]
    
    public func execute(request: LoadConversationRequest) -> Observable<[Conversation]> {
        print("LoadConversationUseCase execute")
        return self.repository
            .loadConversation()
            .asObservable()
    }
}
