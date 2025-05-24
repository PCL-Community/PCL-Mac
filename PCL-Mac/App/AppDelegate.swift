//
//  AppDelegate.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Cocoa
import Zip

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        LogStore.shared.clear()
        log("App 已启动")
        log("正在初始化 Java 列表")
        Task {
            do {
                try await JavaSearch.searchAndSet()
            } catch {
                err("无法初始化 Java 列表: \(error)")
            }
        }
        Zip.addCustomFileExtension("jar")
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        LogStore.shared.save()
        return .terminateNow
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
