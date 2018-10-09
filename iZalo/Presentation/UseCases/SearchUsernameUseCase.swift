//
//  SearchUsernameUsecase.swift
//  iZalo
//
//  Created by CPU11613 on 10/9/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class SearchUsernameUseCase: UseCase {
    private let contactRepository : ContactRepository = ContactRepositoryFactory.sharedInstance
    private let userRepository : UserRepository = UserRepositoryFactory.sharedInstance
    
    public typealias TRequest = SearchUsernameRequest
    public typealias TResponse = ContactSearchResult
    
    public func execute(request: SearchUsernameRequest) -> Observable<ContactSearchResult> {
        return self.contactRepository
            .searchContact(username: request.username, currentUsername: request.currentUsername)
                
    }
}
