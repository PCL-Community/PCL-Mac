//
//  MinecraftLauncher.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/20.
//

import Foundation

public class MinecraftLauncher {
    public static func launch(_ instance: MinecraftInstance) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: instance.config.javaPath)
        process.environment = ProcessInfo.processInfo.environment
        process.arguments = []
        process.arguments!.append(contentsOf: buildJvmArguments(instance))
        process.arguments!.append(instance.manifest.mainClass)
        process.arguments!.append(contentsOf: buildGameArguments(instance))
        debug(process.executableURL!.path + " " + process.arguments!.joined(separator: " "))
        process.currentDirectoryURL = instance.runningDirectory
        
        instance.process = process
        do {
            try process.run()
            process.waitUntilExit()
            instance.process = nil
        } catch {
            err(error.localizedDescription)
        }
    }
    
    private static func buildJvmArguments(_ instance: MinecraftInstance) -> [String] {
        let values: [String: String] = [
            "natives_directory": instance.runningDirectory.appending(path: "natives").path,
            "launcher_name": "PCL Mac",
            "launcher_version": "1.0.0",
            "classpath": buildClasspath(instance)
        ]
        
        var args: [String] = [
            "-Dorg.lwjgl.util.Debug=true",
            "-Djna.tmpdir=${natives_directory}"
        ]
        args.append(contentsOf: instance.manifest.getArguments().getAllowedJVMArguments())
        return replaceTemplateStrings(args, with: values)
    }
    
    private static func buildClasspath(_ instance: MinecraftInstance) -> String {
        var urls: [String] = [
            
        ]
        
        instance.manifest.getAllowedLibraries().forEach { library in
            if let artifact = library.getArtifact() {
                let path: String = instance.runningDirectory.parent().parent().appending(path: "libraries").appending(path: artifact.path).path
                urls.append(path)
            }
        }
        
        urls.append(instance.runningDirectory.appending(path: "\(instance.config.name).jar").path)
        
        return urls.joined(separator: ":")
    }
    
    private static func buildGameArguments(_ instance: MinecraftInstance) -> [String] {
        let values: [String: String] = [
            "auth_player_name": "PCL_Mac",
            "version_name": instance.version.getDisplayName(),
            "game_directory": instance.runningDirectory.path,
            "assets_root": instance.runningDirectory.parent().parent().appending(path: "assets").path,
            "assets_index_name": instance.manifest.assetIndex.id,
            "auth_uuid": "a256e7ba1da830119b633a974279e906",
            "auth_access_token": "9856e9a933b5421cb6cf38f21553bd54",
            "user_type": "msa",
            "version_type": "PCL Mac"
        ]
        return replaceTemplateStrings(instance.manifest.getArguments().getAllowedGameArguments(), with: values)
    }
    
    private static func replaceTemplateStrings(_ strings: [String], with dict: [String: String]) -> [String] {
        return strings.map { original in
            var result = original
            for (key, value) in dict {
                result = result.replacingOccurrences(
                    of: "${\(key)}",
                    with: value
                )
            }
            return result
        }
    }
}
