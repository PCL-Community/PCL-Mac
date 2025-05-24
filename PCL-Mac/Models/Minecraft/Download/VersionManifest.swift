//
//  VersionManifest.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/20.
//

import Foundation

public struct VersionManifest: Codable {
    public struct LatestVersions: Codable {
        public let release: String
        public let snapshot: String
    }
    
    public struct GameVersion: Codable {
        public let id: String
        public let type: String
        public let url: String
        public let time: Date
        public let releaseTime: Date
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
}
