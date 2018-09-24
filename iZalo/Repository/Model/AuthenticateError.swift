//
//  AuthenticateError.swift
//  iZalo
//
//  Created by CPU11613 on 9/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
public class AuthenticateError: Error {
    
    public let errorMessage: String
    
    init(errorMessage: String) {
        self.errorMessage = errorMessage
    }
}
