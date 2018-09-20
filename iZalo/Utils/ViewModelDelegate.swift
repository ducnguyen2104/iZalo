//
//  ViewModelDelegate.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

public protocol ViewModelDelegate {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
