//
//  LibraryVersionMapper.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/28.
//

import Foundation

public struct ArtifactVersionMapper {
    // MARK: 替换本地库下载链接中的架构和版本
    public static func mapNativeUrl(_ name: String, _ downloadUrl: URL) -> URL {
        let splitted: [String] = name.split(separator: ":").map(String.init)
        let groupId: String = splitted[0]
        let artifactId: String = splitted[1]
        let version: String = splitted[2]
        
        let url = mapLwjglNativeUrl(groupId, artifactId, version, downloadUrl) ?? downloadUrl
        
        log("将 \(downloadUrl.path()) 替换为 \(url.path())")
        
        return url
    }
    
    private static func mapLwjglNativeUrl(_ groupId: String, _ artifactId: String, _ version: String, _ downloadUrl: URL) -> URL? {
        var version = version
        if groupId != "org.lwjgl" {
            return nil
        }
        
        var url: URL = downloadUrl
        if version == "3.2.1" || version == "3.1.6" {
            version = "3.3.1"
        }
        if ExecArchitectury.SystemArch == .arm64 {
            if version.hasPrefix("2.") && artifactId == "lwjgl" {
                url = URL(string: "https://repo1.maven.org/maven2/org/glavo/hmcl/lwjgl2-natives/2.9.3-rc1-osx-arm64/lwjgl2-natives-2.9.3-rc1-osx-arm64.jar")!
            } else {
                url = URL(string: "https://libraries.minecraft.net/org/lwjgl/\(artifactId)/\(version)/\(artifactId)-\(version)-natives-macos-arm64.jar")!
            }
        } else {
            url = URL(string: "https://libraries.minecraft.net/org/lwjgl/\(artifactId)/\(version)/\(artifactId)-\(version)-natives-macos-patch.jar")!
        }
        return url
    }
    
    private static func mapLwjglUrl(_ groupId: String, _ artifactId: String, _ version: String, _ downloadUrl: URL) -> URL? {
        var version = version
        if groupId != "org.lwjgl" {
            return nil
        }
        
        if version == "3.2.1" || version == "3.1.6" {
            version = "3.3.1"
        }
        
        return URL(string: "https://libraries.minecraft.net/org/lwjgl/\(artifactId)/\(version)/\(artifactId)-\(version).jar")!
    }
    
    private static func mapJnaUrl(_ groupId: String, _ artifactId: String, _ version: String, _ downloadUrl: URL) -> URL? {
        var version = version
        if groupId != "net.java.dev.jna" {
            return nil
        }
        
        if version == "4.4.0" {
            version = "5.14.0"
        }
        return URL(string: "https://libraries.minecraft.net/net/java/dev/jna/\(artifactId)/\(version)/\(artifactId)-\(version).jar")
    }

    // MARK: 替换依赖项下载链接中的版本
    public static func mapLibraryUrl(_ name: String, _ downloadUrl: URL) -> URL {
        let splitted: [String] = name.split(separator: ":").map(String.init)
        let groupId: String = splitted[0]
        let artifactId: String = splitted[1]
        let version: String = splitted[2]
        
        return mapLwjglUrl(groupId, artifactId, version, downloadUrl) ?? mapJnaUrl(groupId, artifactId, version, downloadUrl) ?? downloadUrl
    }
}
