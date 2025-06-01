//
//  MinecraftManifest.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/20.
//

import Foundation

public struct ClientManifest: Codable {
    public struct AssetIndex: Codable {
        public let id: String
        public let sha1: String
        public let size: Int
        public let totalSize: Int
        public let url: String
    }
    
    public struct DownloadInfo: Codable {
        public let sha1: String
        public let size: Int
        public let url: String
    }
    
    public struct Library: Codable, Hashable {
        public static func == (lhs: Library, rhs: Library) -> Bool {
            return lhs.name == rhs.name
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
        
        public struct Downloads: Codable {
            public struct Artifact: Codable {
                public let path: String
                public let sha1: String
                public let size: Int
                public let url: String
            }
            
            public struct Classifiers: Codable {
                public let nativesMacOS: Artifact?
                public let nativesOsx: Artifact?
                
                public enum CodingKeys: String, CodingKey {
                    case nativesMacOS = "natives-macos"
                    case nativesOsx = "natives-osx"
                }
            }
            
            public let artifact: Artifact?
            public let classifiers: Classifiers?
        }
        
        public struct Natives: Codable {
            public let osx: String?
        }
        
        public let name: String
        public let downloads: Downloads
        public let rules: [Rule]?
        public let natives: Natives?
        
        public func getArtifact() -> Downloads.Artifact? {
            return self.downloads.artifact
        }
        
        public func getNativeArtifact() -> Downloads.Artifact? {
            if let key = natives?.osx,
               let classifiers = downloads.classifiers {
                let nativeArtifact: Downloads.Artifact? = switch key {
                case "natives-osx": classifiers.nativesOsx
                case "natives-macos": classifiers.nativesMacOS
                default: nil
                }
                return nativeArtifact
            }
            return nil
        }
    }
    
    public enum VersionType: String, Codable {
        case release = "release"
        case snapshot = "snapshot"
        case oldBeta = "old_beta"
        case oldAlpha = "oldAlpha"
    }
    
    
    
    public struct Arguments: Codable {
        public enum Value: Codable {
            case string(String)
            case list([String])
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let list = try? container.decode([String].self) {
                    self = .list(list)
                } else {
                    self = .string(try container.decode(String.self))
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .string(let value):
                    try container.encode(value)
                case .list(let value):
                    try container.encode(value)
                }
            }
        }
        
        public enum GameArgument: Codable {
            case string(String)
            case rules(RulesTag)
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let stringValue = try? container.decode(String.self) {
                    self = .string(stringValue)
                } else {
                    self = .rules(try container.decode(RulesTag.self))
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .string(let value):
                    try container.encode(value)
                case .rules(let value):
                    try container.encode(value)
                }
            }
            
            public struct RulesTag: Codable {
                public struct Rule: Codable {
                    public struct Features: Codable {
                        public let isDemoUser: Bool?
                        public let hasCustomResolution: Bool?
                        public let hasQuickPlaysSupport: Bool?
                        public let isQuickPlaySingleplayer: Bool?
                        public let isQuickPlayMultiplayer: Bool?
                        public let isQuickPlayRealms: Bool?
                        
                        public enum CodingKeys: String, CodingKey {
                            case isDemoUser = "is_demo_user"
                            case hasCustomResolution = "has_custom_resolution"
                            case hasQuickPlaysSupport = "has_quick_play_support"
                            case isQuickPlaySingleplayer = "is_quick_play_singleplayer"
                            case isQuickPlayMultiplayer = "is_quick_play_multiplayer"
                            case isQuickPlayRealms = "is_quick_play_realms"
                        }
                        
                        public func match() -> Bool {
                            if let isDemoUser = self.isDemoUser, isDemoUser {
                                return false
                            }
                            
                            if let hasCustomResolution = hasCustomResolution, hasCustomResolution {
                                return false
                            }
                            
                            if let hasQuickPlaysSupport = hasQuickPlaysSupport, hasQuickPlaysSupport {
                                return false
                            }
                            
                            if let isQuickPlaySingleplayer = isQuickPlaySingleplayer, isQuickPlaySingleplayer {
                                return false
                            }
                            
                            if let isQuickPlayMultiplayer = isQuickPlayMultiplayer, isQuickPlayMultiplayer {
                                return false
                            }
                            
                            if let isQuickPlayRealms = isQuickPlayRealms, isQuickPlayRealms {
                                return false
                            }
                            
                            return true
                        }
                    }
                    
                    public let action: Action
                    public let features: Features
                    
                    public func match() -> Bool {
                        return features.match() && action == .allow
                    }
                }
                
                public let rules: [Rule]
                public let value: Value
                
                public func match() -> Bool {
                    var match = true
                    for rule in rules {
                        match = match && rule.match()
                    }
                    return match
                }
            }
        }
        
        public enum JvmArgument: Codable {
            case rules(RulesTag)
            case string(String)
            
            public struct RulesTag: Codable {
                public let rules: [Rule]
                public let value: Value
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let stringValue = try? container.decode(String.self) {
                    self = .string(stringValue)
                } else {
                    self = .rules(try container.decode(RulesTag.self))
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .string(let value):
                    try container.encode(value)
                case .rules(let value):
                    try container.encode(value)
                }
            }
        }
        
        public let game: [GameArgument]
        public let jvm: [JvmArgument]
        
        public func getAllowedGameArguments() -> [String] {
            let filted: [GameArgument] = game.filter { gameArgument in
                return switch gameArgument {
                case .rules(let rules): rules.match()
                default: true
                }
            }
            
            var arguments: [String] = []
            for argument in filted {
                switch argument {
                case .string(let string): arguments.append(string)
                case .rules(let rules):
                    if rules.match() {
                        switch rules.value {
                        case .string(let string): arguments.append(string)
                        case .list(let list): arguments.append(contentsOf: list)
                        }
                    }
                }
            }
            
            return arguments // 什么史山
        }
        
        public func getAllowedJVMArguments() -> [String] {
            var arguments: [String] = []
            
            jvm.filter { jvmArgument in
                switch jvmArgument {
                case .rules(let rules):
                    return rules.rules.allMatch { $0.match() }
                default: return true
                }
            }.forEach { jvmArgument in
                switch jvmArgument {
                case .string(let string):
                    arguments.append(string)
                case .rules(let rules):
                    switch rules.value {
                    case .list(let list):
                        arguments.append(contentsOf: list)
                    case .string(let string):
                        arguments.append(string)
                    }
                }
            }
            return arguments
        }
    }
    
    public let arguments: Arguments?
    public let minecraftArguments: String?
    public let assetIndex: AssetIndex
    public let assets: String
    public let downloads: [String: DownloadInfo]
    public let id: String
    public let libraries: [Library]
    public let mainClass: String
    public let type: VersionType
    
    public static func decode(_ data: Data, _ decoder: JSONDecoder = JSONDecoder()) -> ClientManifest {
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(ClientManifest.self, from: data)
    }
    
    public func getNeededLibraries() -> [Library] {
        return getAllowedLibraries().filter { !$0.name.contains("natives") } // 不能有依赖名字里带 natives 罢
    }
    
    public func getAllowedLibraries() -> [Library] {
        return self.libraries.filter { library in
            var isAllowed: Bool = true
            for rule in library.rules ?? [] {
                isAllowed = isAllowed && rule.os?.match() ?? true && rule.action != .disallow
            }
            return isAllowed
        }
    }
    
    public func getNeededNatives() -> [Library : Library.Downloads.Artifact] {
        var result: [Library : Library.Downloads.Artifact] = [:]
        for library in self.getAllowedLibraries() {
            if let artifact = library.getNativeArtifact() {
                result[library] = artifact
            } else {
                if let artifact = library.getArtifact(),
                   library.name.hasPrefix("org.lwjgl") && library.name.contains("natives") && (ExecArchitectury.SystemArch == .x64 || library.name.hasSuffix("-arm64")) {
                    result[library] = artifact
                }
            }
        }
        
        return result
    }
    
    public func getArguments() -> Arguments {
        if let arguments = self.arguments {
            return arguments
        } else {
            let minecraftArguments = self.minecraftArguments!
            let gameArguments = minecraftArguments.split(separator: " ").map { minecraftArgument in
                return Arguments.GameArgument.string(String(minecraftArgument))
            }
            
            return Arguments(game: gameArguments, jvm: [
                "-XX:+UseG1GC",
                "-XX:-UseAdaptiveSizePolicy",
                "-XX:-OmitStackTraceInFastThrow",
                "-Djava.library.path=${natives_directory}",
                "-Dorg.lwjgl.system.SharedLibraryExtractPath=${natives_directory}",
                "-Dio.netty.native.workdir=${natives_directory}",
                "-Djna.tmpdir=${natives_directory}",
                "-cp", "${classpath}"
            ].map { Arguments.JvmArgument.string($0) }
            )
        }
    }
}

public enum Action: String, Codable {
    case allow = "allow"
    case disallow = "disallow"
}

public struct Rule: Codable {
    public struct OSRule: Codable {
        public let name: String?
        public let arch: String?
        
        public func match() -> Bool {
            var matches = true
            
            if let name = self.name {
                matches = matches && (name == "osx")
            }
            
            // TODO 判断转译是否启用及架构是否匹配
            
            return matches
        }
    }
    
    public let os: OSRule?
    public let action: Action
    
    public func match() -> Bool {
        return os?.match() ?? true && action == .allow
    }
}
