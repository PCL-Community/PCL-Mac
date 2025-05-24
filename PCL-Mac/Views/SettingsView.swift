//
//  SettingsView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(.white)
                .frame(width: 120)
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    MyButtonComponent(text: "打开日志") {
                        NSWorkspace.shared.activateFileViewerSelecting([Constants.ApplicationLogUrl])
                    }
                    .frame(height: 40)
                    .padding()
                    .padding(.bottom, -23)
                    MyButtonComponent(text: "刷新Java列表") {
                        Task {
                            do {
                                try await JavaSearch.searchAndSet()
                            } catch {
                                print("无法刷新Java列表: \(error)")
                            }
                        }
                    }
                    .frame(height: 40)
                    .padding()
                    .padding(.bottom, -23)
                    MyButtonComponent(text: "手动添加Java") {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseFiles = true
                        panel.canChooseDirectories = false
                        
                        if panel.runModal() == .OK {
                            let url = panel.url!
                            if url.lastPathComponent == "java" {
                                if dataManager.javaVirtualMachines.filter({ $0.executableUrl == url }).isEmpty {
                                    let jvm = JavaVirtualMachine.of(url, true)
                                    if !jvm.isError {
                                        LocalStorage.shared.userAddedJVMPaths.append(url)
                                        dataManager.javaVirtualMachines.append(jvm)
                                    } else {
                                        // 错误
                                    }
                                } else {
                                    // 重复
                                }
                            } else {
                                // 可执行文件不正确
                            }
                        }
                    }
                    .frame(height: 40)
                    .padding()
                    .padding(.bottom, -23)
                    MyCardComponent(title: "Java 列表") {
                        VStack {
                            Text("搜索耗时: \(dataManager.lastTimeUsed)ms")
                                .font(.system(size: 14))
                            ForEach(dataManager.javaVirtualMachines) { javaEntity in
                                JavaComponent(jvm: javaEntity)
                            }
                            .animation(.easeInOut(duration: 0.2), value: dataManager.javaVirtualMachines)
                        }
                    }
                    .padding()
                    .foregroundStyle(.black)
                }
            }
        }
        .onAppear {
            if dataManager.javaVirtualMachines.isEmpty {
                Task {
                    do {
                        try await JavaSearch.searchAndSet()
                    } catch { }
                }
            }
        }
    }
}
