//
//  LogManager.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Foundation
import SwiftUI

final class LogStore {
    let dateFormatter = DateFormatter()
    static let shared = LogStore()
    private var logs: [String] = []
    private let maxCapacity = 10_000
    private let writeImmediately = true

    private init() {
        dateFormatter.dateFormat = "[yyyy-MM-dd] [HH:mm:ss.SSS]"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
    }
    
    func append(_ message: String, _ level: String, _ caller: String) {
        if logs.count >= maxCapacity {
            logs.removeFirst(1000)
        }
        let logLine = "\(dateFormatter.string(from: Date())) [\(level)] \(caller): \(message)"
        logs.append(logLine)
        print(logLine)
        if writeImmediately {
            appendToDisk(logLine + "\n")
        }
    }
    
    func appendToDisk(_ content: String, _ callback: ((Bool) -> Void)? = nil) {
        do {
            try FileManager.writeLog(content)
            callback?(true)
        } catch {
            err("日志保存失败: \(error)")
            callback?(false)
        }
    }
    
    func clear() {
        try? FileManager.default.removeItem(at: Constants.ApplicationLogUrl)
    }
    
    func save() {
        if !writeImmediately {
            appendToDisk(logs.joined(separator: "\n")) { isSuccess in
                if isSuccess {
                    log("日志保存成功")
                }
                log("已触发进程终止")
                NSApp.reply(toApplicationShouldTerminate: true)
            }
        }
    }
}

final class Logger {
    static func log(_ message: String, _ caller: String) {
        LogStore.shared.append(message, "LOG", caller)
    }
    
    static func warn(_ message: String, _ caller: String) {
        LogStore.shared.append(message, "WRN", caller)
    }
    
    static func error(_ message: String, _ caller: String) {
        LogStore.shared.append(message, "ERR", caller)
    }
    
    static func debug(_ message: String, _ caller: String) {
#if DEBUG
        LogStore.shared.append(message, "DEBUG", caller)
#endif
    }
}

func log(_ message: Any, file: String = #file, line: Int = #line) {
    Logger.log(String(describing: message), file.split(separator: "/").last! + ":" + String(line))
}

func warn(_ message: Any, file: String = #file, line: Int = #line) {
    Logger.warn(String(describing: message), file.split(separator: "/").last! + ":" + String(line))
}

func err(_ message: Any, file: String = #file, line: Int = #line) {
    Logger.error(String(describing: message), file.split(separator: "/").last! + ":" + String(line))
}

func debug(_ message: Any, file: String = #file, line: Int = #line) {
    Logger.debug(String(describing: message), file.split(separator: "/").last! + ":" + String(line))
}
