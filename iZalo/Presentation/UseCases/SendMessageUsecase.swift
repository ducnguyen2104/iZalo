//
//  SendMessageUsecase.swift
//  iZalo
//
//  Created by CPU11613 on 10/1/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class SendMessageUsecase: UseCase {

    private let messageRepository: MessageRepository =  MessageRepositoryFactory.sharedInstance
    
    public typealias TRequest = SendMessageRequest
    public typealias TResponse = Bool
    
    func execute(request: SendMessageRequest) -> Observable<Bool> {
        return self.messageRepository.sendMessage(request: request)
    }
}
