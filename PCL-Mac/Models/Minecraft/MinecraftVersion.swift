//
//  MinecraftVersion.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/23.
//

import Foundation

public protocol MinecraftVersion: Comparable {
    var releaseDate: Date { get }
    func getDisplayName() -> String
    func isLessThan(_ another: any MinecraftVersion) -> Bool

    static func fromString(_ string: String) -> Self?
}

public extension MinecraftVersion {
    func isLessThan(_ another: any MinecraftVersion) -> Bool {
        return self.releaseDate < another.releaseDate
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.isLessThan(rhs)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.getDisplayName() == rhs.getDisplayName()
    }
}

public func < (lhs: any MinecraftVersion, rhs: any MinecraftVersion) -> Bool {
    lhs.isLessThan(rhs)
}

public func <= (lhs: any MinecraftVersion, rhs: any MinecraftVersion) -> Bool {
    lhs.isLessThan(rhs) || lhs == rhs
}

public func > (lhs: any MinecraftVersion, rhs: any MinecraftVersion) -> Bool {
    !(lhs <= rhs)
}

public func >= (lhs: any MinecraftVersion, rhs: any MinecraftVersion) -> Bool {
    lhs > rhs || lhs == rhs
}

public func == (lhs: any MinecraftVersion, rhs: any MinecraftVersion) -> Bool {
    lhs.getDisplayName() == rhs.getDisplayName()
}

public final class ReleaseMinecraftVersion: MinecraftVersion {
    private let major: Int
    private let minor: Int
    private let patch: Int

    private var _releaseDate: Date?
    public var releaseDate: Date {
        if _releaseDate == nil {
            _releaseDate = VersionManifest.getReleaseDate(self)
        }
        return _releaseDate!
    }

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
}

public final class SnapshotMinecraftVersion: MinecraftVersion {
    private let year: Int
    private let week: Int
    private let id: Character

    private var _releaseDate: Date?
    public var releaseDate: Date {
        if _releaseDate == nil {
            _releaseDate = VersionManifest.getReleaseDate(self)
        }
        return _releaseDate!
    }

    public init(year: Int, week: Int, id: Character) {
        self.year = year
        self.week = week
        self.id = id
    }

    public static func fromString(_ string: String) -> SnapshotMinecraftVersion? {
        let pattern = #"^(\d{2})w(\d{2})([a-z])$"#
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: string.utf16.count)

            if let match = regex.firstMatch(in: string, range: range) {
                guard let yearRange = Range(match.range(at: 1), in: string),
                      let weekRange = Range(match.range(at: 2), in: string) else {
                    return nil
                }

                var id: Character = "a"
                if let idRange = Range(match.range(at: 3), in: string) {
                    id = string[idRange].first!
                }
                return SnapshotMinecraftVersion(year: Int(string[yearRange])!, week: Int(string[weekRange])!, id: id)
            }
        } catch {
            err("正则表达式错误: \(error.localizedDescription)")
        }
        return nil
    }

    public func getDisplayName() -> String {
        return String(format: "%02dw%02d%@", self.year, self.week, String(self.id))
    }
}

public func fromVersionString(_ versionString: String) -> (any MinecraftVersion)? {
    if let version = ReleaseMinecraftVersion.fromString(versionString) {
        return version
    }
    if let version = SnapshotMinecraftVersion.fromString(versionString) {
        return version
    }
    warn("未知的版本格式: \(versionString)")
    return nil
}
