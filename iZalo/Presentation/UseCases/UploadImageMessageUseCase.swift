//
//  UploadImageMessageUseCase.swift
//  iZalo
//
//  Created by CPU11613 on 10/17/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class UploadFileMessageUseCase: UseCase {
    private let repository: MessageRepository = MessageRepositoryFactory.sharedInstance
    
    public typealias TRequest = UploadFileMessageRequest
    public typealias TResponse = String
    
    public func execute(request: UploadFileMessageRequest) -> Observable<String> {
        return repository.uploadFile(request:request)
    }
}
