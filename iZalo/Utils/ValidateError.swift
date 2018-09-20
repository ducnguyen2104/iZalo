//
//  ValidateError.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
class ValidateError: Error {
    
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}
