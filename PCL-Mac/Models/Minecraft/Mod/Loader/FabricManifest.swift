//
//  FabricManifest.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/17.
//

import Foundation
import SwiftyJSON

public class FabricManifest {
    public var libraryUrls: [URL] = []
    public var libraryCoords: [String] = []
    public var libraries: [String] = []
    public let loaderVersion: String
    public let mainClass: String
    
    public init(_ json: JSON) {
        loaderVersion = json["loader"].dictionaryValue["version"]!.stringValue
        if let loader = json["loader"].dictionary?["maven"]?.string {
            libraryCoords.append(loader)
        }
        
        if let intermediary = json["intermediary"].dictionary?["maven"]?.string {
            libraryCoords.append(intermediary)
        }
        
        if let libraries = json["launcherMeta"].dictionary?["libraries"]?.dictionary {
            for key in ["client", "common"] {
                if let libs = libraries[key]?.array {
                    for lib in libs {
                        let name = lib.dictionaryValue["name"]!.stringValue
                        self.libraryCoords.append(name)
                        self.libraryUrls.append(URL(string: lib.dictionaryValue["url"]?.stringValue ?? "https://maven.fabricmc.net")!.appending(path: Util.toPath(mavenCoordinate: name)))
                    }
                }
            }
        }
        
        libraries = libraryCoords.map(Util.toPath(mavenCoordinate:))
        
        let mainClass = json["launcherMeta"].dictionaryValue["mainClass"]!
        if let dict = mainClass.dictionary {
            self.mainClass = dict["client"]!.stringValue
        } else {
            self.mainClass = mainClass.stringValue
        }
    }
    
    public static func parse(_ data: Data) throws -> [FabricManifest] {
        return try JSON(data: data).arrayValue.map(FabricManifest.init)
    }
}
