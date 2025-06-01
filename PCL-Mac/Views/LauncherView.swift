//
//  MainView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/18.
//

import SwiftUI

struct LauncherView: View {
    @ObservedObject private var dataManager: DataManager = DataManager.shared
    
    @State private var instance: MinecraftInstance?
    
    var body: some View {
        VStack {
            MyButtonComponent(text: "测试弹出框") {
                ContentView.setPopup(PopupOverlay("测试", "这是一行文本\n这也是一行文本\n这是一行很\(String(repeating: "长", count: 50))的文本", [.Ok]))
            }
            .frame(height: 40)
            .padding()
            Spacer()
        }
        .onAppear {
            dataManager.leftTab(310) {
                VStack {
                    Spacer()
                    Text("YiZhiMCQiu")
                        .font(.custom("PCL English", size: 16))
                    Spacer()
                    MyButtonComponent(text: "启动游戏", descriptionText: "1.14", foregroundStyle: Color(hex: 0x0A54CA)) {
                        if self.instance == nil {
                            let version = "1.14"
                            let versionUrl = URL(fileURLWithUserPath: "~/PCL-Mac-minecraft/versions/\(version)")
                            self.instance = MinecraftInstance(runningDirectory: versionUrl)
                        }
                        if self.instance!.process == nil {
                            Task {
                                await instance!.run()
                            }
                        }
                    }
                    .frame(width: 280, height: 55)
                    .padding()
                    .padding(.bottom, -27)
                    HStack {
                        MyButtonComponent(text: "版本选择") {
                            
                        }
                        .frame(width: 135, height: 30)
                        .padding(.leading, 10)
                        Spacer()
                        MyButtonComponent(text: "版本设置") {
                            
                        }
                        .frame(width: 135, height: 30)
                        .padding(.trailing, 10)
                    }
                    .frame(width: 300, height: 60)
                }
                .foregroundStyle(Color(hex: 0x343D4A))
            }
        }
    }
}
