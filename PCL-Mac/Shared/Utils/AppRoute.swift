//
//  AppRoute.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/29.
//

import SwiftUI

public enum AppRoute: Hashable {
    // 根页面
    case launch
    case download
    case multiplayer
    case settings
    case others
    
    // 子页面
    case installing(task: InstallTask)
    case versionList
    case modDownload(summary: ModSummary)
    
    // MyList 导航
    case minecraftDownload
    case modSearch
    case about
    case debug
    
    var isRoot: Bool {
        switch self {
        case .launch, .download, .multiplayer, .settings, .others, .minecraftDownload, .modSearch, .about, .debug:
            return true
        default:
            return false
        }
    }
    
    var name: String {
        switch self {
        case .launch: "launch"
        case .download: "download"
        case .multiplayer: "multiplayer"
        case .settings: "settings"
        case .others: "others"
        case .installing(let task): "installing?task=\(task.id)"
        case .versionList: "versionList"
        case .modDownload(let summary): "modDownload?summary=\(summary.id)"
        case .minecraftDownload: "minecraftDownload"
        case .modSearch: "modSearch"
        case .about: "about"
        case .debug: "debug"
        }
    }
}

public class AppRouter: ObservableObject {
    @Published public private(set) var path: [AppRoute] = [.launch]
    
    public func append(_ route: AppRoute) {
        path.append(route)
    }
    
    public func getLastView() -> any View {
        switch getLast() {
        case .launch:
            LaunchView()
        case .download, .minecraftDownload, .modSearch:
            DownloadView()
        case .multiplayer:
            MultiplayerView()
        case .settings:
            SettingsView()
        case .others, .about, .debug:
            OthersView()
        case .installing(let task):
            InstallingView(task: task)
        case .versionList:
            VersionListView()
        case .modDownload(let summary):
            ModDownloadView(summary: summary)
        }
    }
    
    public func getDebugText() -> String {
        return "/" + path.map { $0.name }.joined(separator: "/")
    }
    
    public func removeLast() {
        self.path.removeLast()
        if self.path.isEmpty {
            self.path.append(.launch)
        }
    }
    
    public func setRoot(_ root: AppRoute) {
        path.removeAll()
        path.append(root)
    }
    
    public func getLast() -> AppRoute {
        return path.last!
    }
    
    public func getRoot() -> AppRoute {
        return path.first!
    }
}
