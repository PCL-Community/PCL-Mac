//
//  ArrayExtension.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Foundation

extension Array {
    public func allMatch(_ predicate: @escaping (Element) -> Bool) -> Bool {
        var match = true
        for element in self {
            match = match && predicate(element)
        }
        return match
    }
}
