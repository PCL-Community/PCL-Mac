//
//  LocalStorage.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

public class LocalStorage: ObservableObject {
    public static let shared = LocalStorage()
    
    @AppStorage("user_added_jvm_paths") private var urlStringArray: String = "[]"
    public var userAddedJvmPaths: [URL] {
        get {
            (try? JSONDecoder().decode([String].self, from: Data(urlStringArray.utf8)))?.compactMap { URL(string: $0) } ?? []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue.map { $0.absoluteString }) {
                urlStringArray = String(data: data, encoding: .utf8) ?? "[]"
            }
        }
    }
    
    @AppStorage("theme") private var themeRawValue: String = Theme.pcl.rawValue
    var theme: Theme {
        get { Theme(rawValue: themeRawValue) ?? .pcl }
        set {
            themeRawValue = newValue.rawValue
            objectWillChange.send()
        }
    }
    
    private init() {
        log("已加载持久化储存数据")
    }
}
