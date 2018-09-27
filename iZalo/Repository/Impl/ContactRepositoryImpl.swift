//
//  ContactRepositoryImpl.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class ContactRepositoryImpl: ContactRepository {
    private let remoteSource: ContactRemoteSource
    private let localSource: ContactLocalSource
    private let userRepository: UserRepository
    
    init(remoteSource: ContactRemoteSource,
         localSource: ContactLocalSource,
         userRepository: UserRepository) {
        self.remoteSource = remoteSource
        self.localSource = localSource
        self.userRepository = userRepository
    }
    
    func loadContact() -> Observable<[Contact]> {
        print("ContactRepositoryImpl loadContact")
        return Observable.deferred{
            return self.userRepository
                .loadUser()
                .take(1)
                .flatMap{(user) -> Observable<[Contact]> in
                    guard let user = user else {
                        return Observable.error(AuthenticateError(errorMessage: ""))
                    }
                    
                    return self.remoteSource
                        .getContact(user: user)
            }
        }
    }
    
    func getAvatarURL(username: String) -> Observable<String> {
        return self.remoteSource.getAvatarURL(username: username)
    }
}
