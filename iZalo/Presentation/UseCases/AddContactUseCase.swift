//
//  AddContactUseCase.swift
//  iZalo
//
//  Created by CPU11613 on 10/11/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class AddContactUseCase: UseCase {
    
    private let repository : UserRepository = UserRepositoryFactory.sharedInstance

    public typealias TRequest = AddContactRequest
    public typealias TResponse = Bool
    
    public func execute(request: AddContactRequest) -> Observable<Bool> {
        return self.repository.addContact(request: request)
    }
}
