//
//  DownloadView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct DownloadView: View {
    @ObservedObject private var currentTask: InstallTask = MinecraftInstaller.createTask(URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/1.21"), "1.21")
    
    var body: some View {
        VStack {
            Text(getProgressText())
            Text("剩余: \(currentTask.remainingFiles) / \(getTotalText())")
            Text("当前阶段: \(currentTask.stage.getDisplayName())")
            Text("当前阶段剩余文件数: \(currentTask.leftObjects)")
            MyButtonComponent(text: "启动任务") {
                if currentTask.stage == .before {
                    currentTask.start()
                }
            }
            .frame(height: 40)
            .padding()
        }
    }
    
    private func getProgressText() -> String {
        var text = "进度: "
        if let totalFiles = currentTask.totalFiles {
            text += String(format: "%.2f%%", (1 - Double(currentTask.remainingFiles) / Double(totalFiles)) * 100)
        } else {
            text += "未知"
        }
        return text
    }
    
    private func getTotalText() -> String {
        return currentTask.totalFiles == nil ? "?" : String(currentTask.totalFiles!)
    }
}
