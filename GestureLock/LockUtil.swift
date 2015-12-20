//
// Created by ShinChven Zhang on 15/12/20.
// Copyright (c) 2015 ShinChven Zhang. All rights reserved.
//

import Foundation

class LockUtil {

    static let KEY_PATTERN = "pattern"

    static func savePattern(pattern:Array<Int>){
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(pattern, forKey: KEY_PATTERN)
    }

    static func readPattern() -> Array<Int>?{
        let defaults = NSUserDefaults.standardUserDefaults()
        var pattern:Array<Int>?
        pattern = defaults.objectForKey(KEY_PATTERN) as? Array<Int>
        return pattern
    }
}
