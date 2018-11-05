//
//  LoadAndPlayAudioUseCase.swift
//  iZalo
//
//  Created by CPU11613 on 11/5/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

class LoadAndPlayAudioUseCase: UseCase {
    
    private let repository : MessageRepository = MessageRepositoryFactory.sharedInstance
    
    public typealias TRequest = String
    public typealias TResponse = TimeInterval
    
    public func execute(request: String) -> Observable<TimeInterval> {
        return self.repository
            .loadAndPlayAudio(url: request)
    }
}
