//
//  UserLocalSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol UserLocalSource {
    
    func getUser() -> Observable<User?>
    
    func persistUser(user: User) -> Observable<Bool>
    
//    func removeUser() -> Observable<Bool>
    
//    func persistNotification(notification: Int) -> Observable<Bool>
}

class UserLocalSourceFactory {
        static let sharedInstance: UserLocalSource = UserRealmSource()
}
