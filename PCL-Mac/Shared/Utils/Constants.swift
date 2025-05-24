//
//  Constants.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/20.
//

import Foundation

public struct Constants {
    public static let ApplicationContentsUrl: URL = Bundle.main.bundleURL.appending(path: "Contents")
    public static let ApplicationResourcesUrl: URL = ApplicationContentsUrl.appending(path: "Resources")
    public static let ApplicationLogUrl: URL = ApplicationContentsUrl.appending(path: "Logs").appending(path: "app.log")
    private init() {} // 谁闲的没事初始化这玩意
}
