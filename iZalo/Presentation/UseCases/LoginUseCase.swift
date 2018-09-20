//
//  LoginUseCase.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class LoginUseCase: UseCase {
    
    private let repository : UserRepository = UserRepositoryFactory.sharedInstance
    
    public typealias TRequest = LoginRequest
    public typealias TResponse = Bool
    
    public func execute(request: LoginRequest) -> Observable<Bool> {
        return self.repository
            .login(request: request)
    }
}
