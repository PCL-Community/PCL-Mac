//
//  MinecraftVersion.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/23.
//

import Foundation

public protocol MinecraftVersion: Comparable {
    func getDisplayName() -> String
    static func fromString(_ string: String) -> Self?
}

public final class ReleaseMinecraftVersion: MinecraftVersion {
    private let major: Int
    private let minor: Int
    private let patch: Int
    
    public init(major: Int, minor: Int, patch: Int = 0) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    public static func fromString(_ string: String) -> ReleaseMinecraftVersion? {
        let components = string.components(separatedBy: ".")
        guard components.count >= 2,
              let major = Int(components[0]),
              let minor = Int(components[1]),
              let patch = Int(components.count == 3 ? components[2] : "0") else {
            return nil
        }
        return ReleaseMinecraftVersion(major: major, minor: minor, patch: patch)
    }
    
    public func getDisplayName() -> String {
        return "\(major).\(minor)" + (patch == 0 ? "" : ".\(patch)")
    }
    
    public static func ==(lhs: ReleaseMinecraftVersion, rhs: ReleaseMinecraftVersion) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
    
    public static func <(lhs: ReleaseMinecraftVersion, rhs: ReleaseMinecraftVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else {
            return lhs.patch < rhs.patch
        }
    }
}
