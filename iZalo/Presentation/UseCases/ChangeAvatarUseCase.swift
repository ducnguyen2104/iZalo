//
//  ChangeImageUseCase.swift
//  iZalo
//
//  Created by CPU11613 on 10/15/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class ChangeAvatarUseCase: UseCase {
    private let repository: UserRepository = UserRepositoryFactory.sharedInstance
    
    public typealias TRequest = ChangeAvatarRequest
    public typealias TResponse = String
    
    public func execute(request: ChangeAvatarRequest) -> Observable<String> {
        print("exec change ")
        return repository.changeAvatar(username: request.currentUsername, imagePath: request.imagePath)
    }
}
