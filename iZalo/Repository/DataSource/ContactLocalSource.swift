//
//  ContactLocalSource.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol ContactLocalSource {
    func loadContact() -> Observable<[Contact]>
    func persistContact(contacts: [Contact]) -> Observable<Bool>
}

class ContactLocalSourceFactory {
    public static let sharedInstance: ContactLocalSource = ContactRealmSource()
}
