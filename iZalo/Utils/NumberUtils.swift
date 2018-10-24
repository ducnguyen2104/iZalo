//
//  NumberUtils.swift
//  iZalo
//
//  Created by CPU11613 on 10/24/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation

class NumberUtils {
    public class func RoundDoubleTo6DigitsPrecision(input: Double) -> Double {
        return Double(round(input*1000000)/1000000)
    }
}
