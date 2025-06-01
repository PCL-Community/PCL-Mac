//
//  JavaEntityComponent.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

struct JavaComponent: View {
    let jvm: JavaVirtualMachine
    @State private var isHovered: Bool = false
    
    var body: some View {
        HStack {
            VStack {
                Text("Java \(jvm.version) (\(jvm.displayVersion)) \(jvm.arch) 运行方式: \(jvm.callMethod.getDisplayName())\n\(jvm.executableUrl.path())")
            }
            Spacer()
            if jvm.isAddedByUser {
                Image(systemName: "trash")
                    .onTapGesture {
                        LocalStorage.shared.userAddedJvmPaths.removeAll { $0 == jvm.executableUrl }
                        Task {
                            do {
                                try await JavaSearch.searchAndSet()
                            } catch {
                                err("在删除手动添加的 Java 并刷新 Java 列表时发生错误: \(error)")
                            }
                        }
                    }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: 0xCFCFCF, alpha: 0.5))
        )
        .onHover { hover in
            isHovered = hover
        }
        .foregroundStyle(isHovered ? Color(hex: 0x0B5BCB) : .black)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
    }
}


#Preview {
    SettingsView()
}
