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
    private let userSubject = PublishSubject<User?>()
    
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
                    print("UserRepoImpl persistUser \(user.username)")
                    return self.localSource
                        .persistUser(user: user)
            }
        }
    }
    
    func loadUser() -> Observable<User?> {
        return Observable.deferred { [unowned self] in
            return self.localSource
                .getUser()
                .concat(self.userSubject)
        }
    }
    
    func signup(request: SignUpRequest) -> Observable<Bool> {
        return Observable<Bool>.just(true)
    }
    
}
