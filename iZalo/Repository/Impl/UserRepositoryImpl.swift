//
//  UserRepositoryImpl.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class UserRepositoryImpl: UserRepository {
    
    private let remoteSource: UserRemoteSource
    private let localSource: UserLocalSource

    init(remoteSource: UserRemoteSource,
         localSource: UserLocalSource) {
        self.remoteSource = remoteSource
        self.localSource = localSource
    }
    
    func login(request: LoginRequest) -> Observable<Bool> {
        return Observable.deferred { [unowned self] in
            return self.remoteSource
                .login(request: request)
                .flatMap { [unowned self] (user) -> Observable<Bool> in
                    return self.localSource
                        .persistUser(user: user)
            }
        }
    }
    
    func signup(request: SignUpRequest) -> Observable<Bool> {
        return Observable<Bool>.just(true)
    }
    
}
