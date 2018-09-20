//
//  ParseDataError.swift
//  iZalo
//
//  Created by CPU11613 on 9/19/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

public class ParseDataError: Error {
    
    public let error: NSError
    public let errorMessage: String
    
    init(parseClass: String, errorMessage: String) {
        let bundle = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        self.error = NSError(domain: bundle + parseClass, code: -1, userInfo: nil)
        self.errorMessage = errorMessage
    }
}
