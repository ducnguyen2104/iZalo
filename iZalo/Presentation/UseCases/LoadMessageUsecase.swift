//
//  LoadMessageUsecase.swift
//  iZalo
//
//  Created by CPU11613 on 10/1/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class LoadMessageUseCase: UseCase {

    
    private let repository: MessageRepository = MessageRepositoryFactory.sharedInstance
    
    public typealias TRequest = LoadMessageRequest
    public typealias TResponse = [Message]
    
    public func execute(request: LoadMessageRequest) -> Observable<[Message]> {
        return self.repository
            .loadMessage(conversation: request.conversation)
            .asObservable()
    }
}
