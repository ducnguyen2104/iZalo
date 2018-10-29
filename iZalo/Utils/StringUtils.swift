//
//  StringUtils.swift
//  iZalo
//
//  Created by CPU11613 on 10/29/18.
//  Copyright © 2018 CPU11613. All rights reserved.
//

import Foundation
class StringUtils {

    public class func replaceWithEmojis(s: String) -> String {
        return s.replacingOccurrences(of: ":D", with: "😃")
            .replacingOccurrences(of: ":)", with: "🙂")
            .replacingOccurrences(of: ":(", with: "🙁")
            .replacingOccurrences(of: "🙁(", with: "😭")
            .replacingOccurrences(of: "🙂)", with: "😆")
    }
}

