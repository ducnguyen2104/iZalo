//
//  ContactRemoteSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol ContactRemoteSource {
    func getContact(user: User) -> Observable<[Contact]>
    func getAvatarURL(username: String) -> Observable<String>
}

class ContactRemoteSourceFactory {
    static let sharedInstance: ContactRemoteSource = ContactFirebaseSource()
}
