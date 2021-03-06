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
    
    func loadUser(username: String) -> Observable<User?> {
        return Observable.deferred { [unowned self] in
            return self.localSource
                .getUser(username: username)
                .concat(self.userSubject)
        }
    }
    
    func signup(request: SignupRequest) -> Observable<User> {
        return self.remoteSource.signup(request: request)
    }
    
    func getAvatarURL(username: String) -> Observable<String> {
        return self.remoteSource.getAvatarURL(username: username)
    }
    
    func addContact(request: AddContactRequest) -> Observable<Bool>  {
        return self.remoteSource.addContact(request: request)
    }
    
    func changeAvatar(username: String, imagePath: URL) -> Observable<String> {
        print("userRepo change avt")
        return self.remoteSource.changeAvatar(username: username, imagePath: imagePath).flatMap{(newURL) -> Observable<String> in
            self.localSource.updateAvatarURL(username: username, newURL: newURL)
        }
    }
}
