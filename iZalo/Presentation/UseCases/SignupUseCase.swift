//
//  SignupUseCase.swift
//  iZalo
//
//  Created by CPU11613 on 10/9/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class SignupUseCase: UseCase {
    private let repository : UserRepository = UserRepositoryFactory.sharedInstance
    
    public typealias TRequest = SignupRequest
    public typealias TResponse = User
    
    public func execute(request: SignupRequest) -> Observable<User> {
        return self.repository
            .signup(request: request)
    }
}
