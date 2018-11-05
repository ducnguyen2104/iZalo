//
//  PersistMessageUseCase.swift
//  iZalo
//
//  Created by CPU11613 on 11/5/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class PersistMessageUseCase: UseCase {
    
    private let repository : MessageRepository = MessageRepositoryFactory.sharedInstance
    
    public typealias TRequest = Message
    public typealias TResponse = [Message]
    
    public func execute(request: Message) -> Observable<[Message]> {
        return self.repository
            .persistMessage(message:request)
    }
}
