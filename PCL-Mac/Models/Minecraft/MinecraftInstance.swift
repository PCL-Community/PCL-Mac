//
//  MinecraftVersion.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/20.
//

import Foundation

public class MinecraftInstance {
    private static let RequiredJava17: ReleaseMinecraftVersion = ReleaseMinecraftVersion.fromString("1.18")!
    private static let RequiredJava21: ReleaseMinecraftVersion = ReleaseMinecraftVersion.fromString("1.21")!
    
    public let runningDirectory: URL
    public let version: any MinecraftVersion
    public var process: Process?
    public let manifest: ClientManifest!
    public var config: MinecraftConfig
    
    public init?(runningDirectory: URL, config: MinecraftConfig? = nil) {
        self.runningDirectory = runningDirectory
        
        do {
            let handle = try FileHandle(forReadingFrom: runningDirectory.appending(path: runningDirectory.lastPathComponent + ".json"))
            manifest = .decode(try handle.readToEnd()!)
            version = fromVersionString(manifest.id)!
        } catch {
            err("无法加载客户端 JSON: \(error)")
            return nil
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
                guard FileManager.default.fileExists(atPath: configPath.path) else {
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
        
        // 检查 Java 路径是否存在
        if self.config.javaPath == nil {
            self.config.javaPath = MinecraftInstance.findSuitableJava(version)?.executableUrl.path
        }
    }
    
    public static func findSuitableJava(_ version: any MinecraftVersion) -> JavaVirtualMachine? {
        let needsJava17: Bool = version >= RequiredJava17
        let needsJava21: Bool = version >= RequiredJava21
        
        var suitableJava: JavaVirtualMachine?
        for jvm in DataManager.shared.javaVirtualMachines.sorted(by: { $0.version < $1.version }) {
            if (jvm.version < 17 && needsJava17) || (jvm.version < 21 && needsJava21) {
                continue
            }
            
            suitableJava = jvm
            
            if jvm.callMethod == .direct {
                break
            }
        }
        return suitableJava
    }
    
    public func run() async {
        MinecraftLauncher.launch(self)
    }
}

public struct MinecraftConfig: Codable {
    public let name: String
    public var javaPath: String!
    
    public init(name: String, javaPath: String? = nil) {
        self.name = name
        self.javaPath = javaPath
    }
}
