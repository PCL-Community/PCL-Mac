//
//  JavaSearch.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import Foundation

public class JavaSearch {
    public static var highestVersion: Int!
    private static var javaVirtualMachines: [JavaVirtualMachine] = []
    private static var lastTimeUsed: Int = 0
    
    @MainActor
    public static func updateData() {
        DataManager.shared.javaVirtualMachines = javaVirtualMachines
        DataManager.shared.lastTimeUsed = lastTimeUsed
    }
    
    public static func searchAndSet() async throws {
        let before = Date().timeIntervalSince1970
        javaVirtualMachines = try await search()
        lastTimeUsed = Int((Date().timeIntervalSince1970 - before) * 1000)
        log("搜索 Java 耗时 \(lastTimeUsed)ms")
        highestVersion = javaVirtualMachines.sorted { jvm1, jvm2 in
            return jvm1.version > jvm2.version
        }[0].version
        
        for i in 0..<javaVirtualMachines.count {
            if javaVirtualMachines[i].version == 0 {
                javaVirtualMachines[i].version = highestVersion
                javaVirtualMachines[i].displayVersion = String(highestVersion)
            }
        }
        loadCustomJVMs()
        await updateData()
    }
    
    private static func loadCustomJVMs() {
        LocalStorage.shared.userAddedJvmPaths.forEach{ javaVirtualMachines.append(JavaVirtualMachine.of($0, true)) }
        log("加载了 \(LocalStorage.shared.userAddedJvmPaths.count) 个由用户添加的 Java")
    }
    
    public static func search() async throws -> [JavaVirtualMachine] {
        var dirs: [String] = []
        dirs.append("/usr/bin")
        let jvmDirsRanges = [
            "/Library/Java/JavaVirtualMachines",
            "~/Library/Java/JavaVirtualMachines",
            "/opt/homebrew/opt/java/libexec"
        ]
        jvmDirsRanges.forEach { jvmDirsPath in
            do {
                let jvmFolders = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: jvmDirsPath), includingPropertiesForKeys: [.isDirectoryKey])
                    .filter { path in
                        var isDirectory: ObjCBool = false
                        return FileManager.default.fileExists(atPath: path.path(), isDirectory: &isDirectory) && isDirectory.boolValue && isValidJvmDirectory(path)
                    }
                    .map{ toJvmDirectory($0).path() }
                dirs.append(contentsOf: jvmFolders)
            } catch { }
        }
        return dirs.map { JavaVirtualMachine.of(URL(fileURLWithPath: $0.replacingOccurrences(of: "~", with: FileManager.default.homeDirectoryForCurrentUser.path)).appending(path: "java")) }
    }
    
    private static func isValidJvmDirectory(_ path: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return FileManager.default.fileExists(atPath: toJvmDirectory(path).appending(path: "java").path(), isDirectory: &isDirectory) && !isDirectory.boolValue
    }
    
    private static func toJvmDirectory(_ path: URL) -> URL {
        return path.appending(path: "Contents").appending(path: "Home").appending(path: "bin")
    }
}
