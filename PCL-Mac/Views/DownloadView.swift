//
//  DownloadView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct DownloadView: View {
    @ObservedObject var dataManager = DataManager.shared
    
    @State var versionViews: [String: [VersionView]] = [:]
    @State var currentDownloadPage: DownloadPage?
    
    struct VersionView: View, Identifiable {
        enum IconType: String {
            case release = "Release"
            case snapshot = "Snapshot"
        }
        
        let name: String
        let description: String
        let icon: IconType
        let parent: DownloadView
        let version: VersionManifest.GameVersion
        
        let id: UUID = UUID()
        
        init(version: VersionManifest.GameVersion, isLatest: Bool = false, parent: DownloadView) {
            self.name = version.id
            
            var description = SharedConstants.shared.dateFormatter.string(from: version.releaseTime)
            if isLatest {
                description = "最新\(version.type == "release" ? "正式" : "预览")版，发布于 " + description
            }
            self.description = description
            
            self.icon = IconType(rawValue: version.type.capitalized)!
            self.parent = parent
            self.version = version
        }
        
        @State private var isHovered: Bool = false
        
        var body: some View {
            HStack {
                Image(self.icon.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35)
                    .padding(.leading, 5)
                VStack(alignment: .leading) {
                    Text(self.name)
                        .font(.custom("PCL English", size: 14))
                        .foregroundStyle(Color(hex: 0x343D4A))
                        .padding(.top, 5)
                    Text(self.description)
                        .font(.custom("PCL English", size: 14))
                        .foregroundStyle(Color(hex: 0x7F8790))
                        .padding(.bottom, 5)
                }
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(self.isHovered ? Color(hex: 0xE6EDFE) : .white)
                    .frame(height: 40)
            )
            .animation(.easeInOut(duration: 0.2), value: self.isHovered)
            .onHover { hover in
                self.isHovered = hover
            }
            .onTapGesture {
                self.parent.onVersionClicked(version)
            }
            .padding(.top, -8)
        }
    }
    
    var body: some View {
        HStack {
            if let currentDownloadPage = self.currentDownloadPage {
                currentDownloadPage
                    .zIndex(0)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        if let manifest = dataManager.versionManifest {
                            StaticMyCardComponent(title: "最新版本") {
                                VStack {
                                    VersionView(version: manifest.getLatestRelease(), isLatest: true, parent: self)
                                    VersionView(version: manifest.getLatestSnapshot(), isLatest: true, parent: self)
                                }
                                .padding(.top, 12)
                            }
                        }
                        
                        if let releases = self.versionViews["release"] {
                            MyCardComponent(title: "正式版 (\(releases.count))") {
                                LazyVStack {
                                    ForEach(releases) { view in
                                        view
                                    }
                                }
                                .padding(.top, 12)
                            }
                            .padding(.top, 10)
                        }
                        
                        if let snapshots = self.versionViews["snapshot"] {
                            MyCardComponent(title: "预览版 (\(snapshots.count))") {
                                LazyVStack {
                                    ForEach(snapshots) { view in
                                        view
                                    }
                                }
                                .padding(.top, 12)
                            }
                            .padding(.top, 10)
                        }
                        Spacer()
                    }
                    .padding()
                }
                .zIndex(0)
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: currentDownloadPage == nil)
        .onAppear {
            dataManager.leftTab(170) {
                EmptyView()
            }
            self.versionViews["release"] = createViewsFromVersion(type: "release")
            self.versionViews["snapshot"] = createViewsFromVersion(type: "snapshot")
        }
    }
    
    func createViewsFromVersion(type: String) -> [VersionView] {
        guard let versionManifest = dataManager.versionManifest else {
            return []
        }
        return versionManifest.versions.filter { $0.type == type }.map { VersionView(version: $0, parent: self)}
    }
    
    func onVersionClicked(_ version: VersionManifest.GameVersion) {
        if let version = version.parse() {
            self.currentDownloadPage = DownloadPage(version) {
                self.currentDownloadPage = nil
            }
        } else {
            err("无法解析版本: \(version.id)")
        }
    }
}

struct DownloadPage: View {
    let version: any MinecraftVersion
    let back: () -> Void
    
    @State private var icon: String = "Release"
    @State private var name: String
    
    @ObservedObject private var currentTask: Holder<InstallTask> = Holder()
    
    init(_ version: any MinecraftVersion, _ back: @escaping () -> Void) {
        self.version = version
        self.name = version.getDisplayName()
        self.back = back
    }
    
    var body: some View {
        ZStack {
            VStack {
                TitlelessMyCardComponent {
                    HStack(alignment: .center) {
                        Image("Back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15)
                            .foregroundStyle(Color(hex: 0x96989A))
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                            .onTapGesture {
                                back()
                            }
                        Image(icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35)
                        MyTextFieldComponent(text: self.$name)
                            .foregroundStyle(Color(hex: 0x343D4A))
                    }
                }
                .padding()
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    RoundedButton {
                        HStack {
                            Image("DownloadItem")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                            Text("开始下载")
                                .font(.custom("PCL English", size: 16))
                        }
                    } onClick: {
                        self.currentTask.setObject(MinecraftInstaller.createTask(version, name, MinecraftDirectory(rootUrl: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft"))))
                        DataManager.shared.router.append(.installing(task: self.currentTask.object!))
                        self.currentTask.object!.start()
                    }
                    .foregroundStyle(.white)
                    .padding()
                    Spacer()
                }
            }
        }
    }
    
    struct RoundedButton<Content: View>: View {
        let content: () -> Content
        let onClick: () -> Void
        
        @State private var isHovered: Bool = false
        @State private var isPressed: Bool = false
        
        var body: some View {
            content()
                .padding()
                .padding(.leading, 10)
                .padding(.trailing, 10)
                .background(
                    RoundedRectangle(cornerRadius: .infinity)
                        .fill(Color(hex: 0x1370F3))
                )
                .scaleEffect(isPressed ? 0.85 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isHovered)
                .animation(.easeInOut(duration: 0.2), value: isPressed)
                .onHover {
                    isHovered = $0
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            isPressed = true
                        }
                        .onEnded { value in
                            if isPressed {
                                onClick()
                            }
                            isPressed = false
                        }
                )
        }
    }
}

#Preview {
    DownloadView(currentDownloadPage: DownloadPage(ReleaseMinecraftVersion.fromString("1.21")!) {})
        .background(Color(hex: 0xC5D2E9))
}
