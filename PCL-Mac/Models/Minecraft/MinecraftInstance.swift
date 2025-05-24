//
//  MinecraftVersion.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/20.
//

import Foundation

public class MinecraftInstance {
    public let runningDirectory: URL
    public let version: any MinecraftVersion
    public var process: Process?
    public let manifest: ClientManifest!
    public let config: MinecraftConfig
    
    public init?(runningDirectory: URL, version: any MinecraftVersion, _ config: MinecraftConfig? = nil) {
        self.runningDirectory = runningDirectory
        self.version = version
        
        do {
            let handle = try FileHandle(forReadingFrom: runningDirectory.appending(path: runningDirectory.lastPathComponent + ".json"))
            self.manifest = .decode(try handle.readToEnd()!)
        } catch {
            err("无法加载客户端 JSON: \(error)")
            self.manifest = nil
        }
        let configPath = runningDirectory.appending(path: ".PCL_Mac.json")
        
        if let config = config {
            self.config = config
            // 保存配置
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do {
                try FileManager.default.createDirectory(
                    at: runningDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                try encoder.encode(config).write(to: configPath, options: .atomic)
            } catch {
                err("无法保存配置: \(error)")
                // 不返回 nil，能跑就行
            }
        } else {
            do {
                guard FileManager.default.fileExists(atPath: configPath.path()) else {
                    err("在传入的 config 为 nil 时，应有对应的配置文件")
                    return nil
                }
                let handle = try FileHandle(forReadingFrom: configPath)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                self.config = try! decoder.decode(MinecraftConfig.self, from: handle.readToEnd()!)
            } catch {
                err("无法加载客户端配置: \(error)")
                return nil
            }
        }
    }
    
    public func run() {
        MinecraftLauncher.launch(self)
    }
}

public struct MinecraftConfig: Codable {
    public let name: String
    public let javaPath: String
    
    public init(name: String, javaPath: String) {
        self.name = name
        self.javaPath = javaPath
    }
}
