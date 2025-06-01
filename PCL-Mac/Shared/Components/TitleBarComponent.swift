//
//  TitleBar.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/17.
//

import SwiftUI

struct DraggableWindowArea<Content: View>: NSViewRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeNSView(context: Context) -> NSHostingView<Content> {
        let hostingView = NSHostingView(rootView: content)
        hostingView.addSubview(DraggableHelperView())
        hostingView.subviews.last?.frame = hostingView.bounds
        hostingView.subviews.last?.autoresizingMask = [.width, .height]
        return hostingView
    }

    func updateNSView(_ nsView: NSHostingView<Content>, context: Context) {
        nsView.rootView = content
    }
}

class DraggableHelperView: NSView {
    override func mouseDown(with event: NSEvent) {
        if let window = self.window {
            window.performDrag(with: event)
        }
    }
    override func hitTest(_ point: NSPoint) -> NSView? {
        return self
    }
}

struct GenericTitleBarComponent<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack {
            ZStack {
                DraggableWindowArea {
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                HStack(alignment: .center) {
                    content()
                    Spacer()
                    WindowControlButton.Miniaturize
                    WindowControlButton.Close
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 47)
        .background(
            LocalStorage.shared.theme.getGradientView()
        )
    }
}

struct TitleBarComponent: View {
    var body: some View {
        GenericTitleBarComponent {
            Group {
                Image("TitleLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 19)
                    .bold()
                Tag(text: "Mac", color: .white)
                    .foregroundStyle(LocalStorage.shared.theme.gradientOr(Color(hex: 0x1269E4)))
                    .padding(.leading, 10)
                Spacer()
                MenuItemButton(route: .launcher, parent: self)
                MenuItemButton(route: .download, parent: self)
                MenuItemButton(route: .multiplayer, parent: self)
                MenuItemButton(route: .settings, parent: self)
                MenuItemButton(route: .others, parent: self)
            }
        }
    }
}

struct SubviewTitleBarComponent: View {
    @ObservedObject private var dataManager: DataManager = DataManager.shared

    var body: some View {
        GenericTitleBarComponent {
            Image("Back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 18)
                .onTapGesture {
                    dataManager.router.removeLast()
                }
                .padding(.trailing, 5)
            Text(getTitle())
                .font(.custom("PCL English", size: 16))
        }
    }
    
    private func getTitle() -> String {
        switch dataManager.router.getLast() {
        case .installing(_):
            return "下载管理"
        default:
            return "发现问题请在 https://github.com/PCL-Community/PCL-Mac/issues/new 上反馈"
        }
    }
}

struct MenuItemButton: View {
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    
    let route: AppRoute
    let parent: TitleBarComponent
    var icon: Image?
    @State private var isHovered = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .foregroundStyle(dataManager.router.getRoot() == route ? .white : (isHovered ? Color(hex: 0xFFFFFF, alpha: 0.17) : .clear))
            
            HStack {
                getImage()
                    .renderingMode(.template)
                    .interpolation(.high)
                    .resizable()
                    .foregroundStyle(dataManager.router.getRoot() == route ?
                                     AnyShapeStyle(LocalStorage.shared.theme.gradientOr(Color(hex: 0x1269E4))) : AnyShapeStyle(.white))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .position(x: 17, y: 13)
                Text(getText())
                    .foregroundStyle(dataManager.router.getRoot() == route ?
                                     AnyShapeStyle(LocalStorage.shared.theme.gradientOr(Color(hex: 0x1269E4))) : AnyShapeStyle(.white))
                    .position(x: 9, y: 13)
            }
        }
        .frame(width: 75, height: 27)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.2), value: dataManager.router.getRoot() == route)
        .onTapGesture {
            dataManager.router.setRoot(route)
        }
        .onHover { hover in
            isHovered = hover
        }
    }
    
    private func getImage() -> Image {
        let key = switch route {
        case .launcher: "LaunchItem"
        case .download: "DownloadItem"
        case .multiplayer: "MultiplayerItem"
        case .settings: "SettingsItem"
        case .others: "OthersItem"
        default: ""
        }
        return Image(key)
    }
    
    private func getText() -> String {
        return switch route {
        case .launcher: "启动"
        case .download: "下载"
        case .multiplayer: "联机"
        case .settings: "设置"
        case .others: "更多"
        default: ""
        }
    }
}

struct Tag: View {
    let text: String
    let color: Color
    
    var body: some View {
        ZStack {
            Text(text)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(color)
                        .frame(width: 32, height: 21)
                )
        }
    }
}

#Preview {
    SubviewTitleBarComponent()
}
