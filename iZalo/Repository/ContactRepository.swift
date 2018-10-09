//
//  ContactRepository.swift
//  iZalo
//
//  Created by CPU11613 on 9/26/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

protocol ContactRepository {
    func loadContacts(username: String) -> Observable<[Contact]>
    
    func getContactInfo(username: String) -> Observable<Contact>
    
    func getAvatarURL(username: String) -> Observable<String>
    
    func searchContact(username: String, currentUsername: String) -> Observable<ContactSearchResult>
}

class ContactRepositoryFactory {
    public static let sharedInstance: ContactRepository = ContactRepositoryImpl(remoteSource: ContactRemoteSourceFactory.sharedInstance, localSource: ContactLocalSourceFactory.sharedInstance, userRepository: UserRepositoryFactory.sharedInstance)
}
