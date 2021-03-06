//
//  UserRepository.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol UserRepository {
    
    func login(request: LoginRequest) -> Observable<Bool>
    
//    func autoLogin() -> Observable<Bool>
    
    func signup(request: SignupRequest) -> Observable<User>
    
//    func logout() -> Observable<Bool>
    
    func loadUser(username: String) -> Observable<User?>
    
    func getAvatarURL(username: String) -> Observable<String>
    
    func addContact(request: AddContactRequest) -> Observable<Bool>
    
    func changeAvatar(username: String, imagePath: URL) -> Observable<String>
    
//    func loadProfile() -> Observable<User>
    
    //func updateProfile(request: UpdateProfileRequest) -> Observable<Bool>
    
    //func changePassword(request: ChangePassRequest) -> Observable<Bool>
    
    //func changeAvatar(request: ChangeAvatarRequest) -> Observable<Bool>
    
    //func resetPassword(request: ResetPassRequest) -> Observable<Bool>
    
//    func setNotification(notification: Int) -> Observable<Bool>
    
//    func updateFirebase(token: String) -> Observable<Bool>
}

class UserRepositoryFactory {

    public static let sharedInstance: UserRepository = UserRepositoryImpl(remoteSource: UserRemoteSourceFactory.sharedInstance, localSource: UserLocalSourceFactory.sharedInstance)
}
