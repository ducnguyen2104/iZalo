//
//  LoadCurrenUserInfo.swift
//  iZalo
//
//  Created by CPU11613 on 10/15/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class LoadCurrentUserInfoUseCase: UseCase {
    private let repository: UserRepository = UserRepositoryFactory.sharedInstance
    
    public typealias TRequest = String
    public typealias TResponse = User?
    
    public func execute(request: String) -> Observable<User?> {
        return self.repository
            .loadUser(username: request)
    }
}
