//
//  VersionList.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/1.
//

import SwiftUI

struct VersionListView: View {
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    
    let minecraftDirectory: MinecraftDirectory = MinecraftDirectory(rootUrl: URL(fileURLWithUserPath: "~/PCL-Mac-minecraft"))
    
    struct VersionView: View, Identifiable {
        enum IconType: String {
            case release = "Release"
            case snapshot = "Snapshot"
        }
        
        let name: String
        let description: String
        let icon: IconType
        let instance: MinecraftInstance
        
        let id: UUID = UUID()
        
        init(instance: MinecraftInstance) {
            self.name = instance.config.name
            self.description = instance.version.displayName
            self.icon = .release
            self.instance = instance
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
                    .fill(isHovered ? Color(hex: 0xE6EDFE) : .white)
                    .frame(height: 40)
            )
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hover in
                isHovered = hover
            }
            .onTapGesture {
                LocalStorage.shared.defaultInstance = instance.config.name
                DataManager.shared.router.removeLast()
            }
            .padding(.top, -8)
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                MyCardComponent(title: "常规版本") {
                    VStack {
                        ForEach(minecraftDirectory.getInnerInstances()) { instance in
                            VersionView(instance: instance)
                        }
                    }
                    .padding(.top, 12)
                }
                .padding()
            }
        }
        .onAppear {
            dataManager.leftTab(350) {
                EmptyView()
            }
        }
    }
}

#Preview {
    VersionListView()
}
