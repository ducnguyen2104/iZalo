//
//  UseCase.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
import RxSwift

public protocol UseCase {
    associatedtype TRequest
    associatedtype TResponse
    
    func execute(request: TRequest) -> Observable<TResponse>
}
