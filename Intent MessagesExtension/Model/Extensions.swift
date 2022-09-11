//
//  Extensions.swift
//  Intent MessagesExtension
//
//  Created by Josh Mitchell on 07/03/2022.
//

import Foundation

extension String {
    func getChecked() -> Bool {
        if self.split(separator: ":")[0] == "n" {
            return false
        } else {
            return true
        }
    }
    
    func toggleChecked() -> String {
        var str = self
        if str.starts(with: "n") {
            str = str.replacingOccurrences(of: "n:", with: "y:")
        } else {
            str = str.replacingOccurrences(of: "y:", with: "n:")
        }
        return str
    }
    
    func getMessage() -> String {
        if (self == "n:") || (self == "y:") { return "" }
        print("self is ", self)
        return String(self.split(separator: ":")[1])
    }
    
    func unStringify() -> [String] {
        let arr = self.split(separator: "|")
        var strArr: [String] = []
        for str in arr {
            strArr.append(String(str))
        }
        return strArr
    }

}

extension Array {
    func stringify() -> String {
        var newStr = ""
        for str in self {
            newStr += str as! String
            newStr += "|"
        }
        return newStr
    }
    
    func getCheckedCount() -> Int {
        let intentions = self as! [String]
        var count = 0
        for intention in intentions {
            if intention.getChecked() {
                count += 1
            }
        }
        return count
    }
}
