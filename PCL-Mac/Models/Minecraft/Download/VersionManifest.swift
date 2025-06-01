//
//  VersionManifest.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/20.
//

import Foundation

public class VersionManifest: Codable {
    public struct LatestVersions: Codable {
        public let release: String
        public let snapshot: String
    }
    
    public struct GameVersion: Codable {
        public enum VersionType: String, Codable {
            case release = "release"
            case snapshot = "snapshot"
            case oldBeta = "old_beta"
            case alpha = "old_alpha"
        }
        
        public let id: String
        public let type: String
        public let url: String
        public let time: Date
        public let releaseTime: Date
        
        public func parse() -> (any MinecraftVersion)? {
            switch self.type {
            case "release": ReleaseMinecraftVersion.fromString(self.id)
            case "snapshot": SnapshotMinecraftVersion.fromString(self.id)
            default: nil
            }
        }
    }
    
    public let latest: LatestVersions
    public let versions: [GameVersion]
    
    public static func fetchLatestData(_ callback: @escaping (VersionManifest) -> Void) {
        debug("正在获取最新版本数据")
        var request = URLRequest(url: URL(string: "https://launchermeta.mojang.com/mc/game/version_manifest.json")!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let result = String(data: data, encoding: .utf8) {
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let data = Data(result.utf8)
                    let manifest = try decoder.decode(VersionManifest.self, from: data)
                    
                    callback(manifest)
                } catch {
                    err("解析失败: \(error)")
                }
            }
        }.resume()
    }
    
    public func getLatestRelease() -> GameVersion {
        return self.versions.find { $0.id == self.latest.release }!
    }
    
    public func getLatestSnapshot() -> GameVersion {
        return self.versions.find { $0.id == self.latest.snapshot }!
    }
    
    public static func getReleaseDate(_ version: any MinecraftVersion) -> Date? {
        if let manifest = DataManager.shared.versionManifest {
            return manifest.versions.find { $0.id == version.getDisplayName() }?.releaseTime // 需要缓存
        } else {
            warn("正在获取发布日期，但版本清单未初始化完成") // 布什隔门
        }
        return nil
    }
}
