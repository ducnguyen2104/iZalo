//
//  UserRemoteSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol UserRemoteSource {
    
    func login(request: LoginRequest) -> Observable<User>
    
//    func autoLogin(user: User) -> Observable<User>
    
    func signup(request: SignUpRequest) -> Observable<User>
      
//    func loadProfile(user: User) -> Observable<User>
    
//    func updateProfile(request: UpdateProfileRequest, user: User) -> Observable<Bool>
    
//    func changePassword(request: ChangePassRequest, user: User) -> Observable<Bool>
    
//    func changeAvatar(request: ChangeAvatarRequest, user: User) -> Observable<Bool>
    
//    func resetPassword(request: ResetPassRequest) -> Observable<Bool>
    
//    func changeNotification(notification: Int, user: User) -> Observable<Bool>
    
//    func updateFirebase(token: String, user: User) -> Observable<Bool>
}

class UserRemoteSourceFactory {
        static let sharedInstance: UserRemoteSource = UserFirebaseSource()
}
