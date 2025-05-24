//
//  PCL_MacTests.swift
//  PCL-MacTests
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import Testing
import Foundation
import PCL_Mac

struct PCL_MacTests {

    @Test func runTest() async throws {
        let version = "1.14"
        let versionUrl = URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/\(version)")
        let instance = MinecraftInstance(runningDirectory: versionUrl, version: ReleaseMinecraftVersion.fromString(version)!, MinecraftConfig(name: "Test", javaPath: "/usr/bin/java"))
        instance!.run()
    }
    
    @Test func loadClientManifestTest() async throws {
        let handle = try FileHandle(forReadingFrom: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/1.21/1.21.json"))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let manifest = try decoder.decode(ClientManifest.self, from: handle.readToEnd()!)
        print(manifest.getArguments().getAllowedGameArguments())
    }
    
    @Test func downloadTest() async throws {
        var isRunning = true
        let version = "1.12"
        let versionUrl = URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/\(version)")
        MinecraftInstaller.createTask(versionUrl, version) {
            isRunning = false
        }.start()
        while isRunning {}
    }
}
