//
//  ModDownloadView.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/6/20.
//

import SwiftUI

struct ModDownloadView: View {
    @ObservedObject private var dataManager: DataManager = .shared
    @ObservedObject var summary: ModSummary
    
    var body: some View {
        ScrollView {
            TitlelessMyCardComponent {
                VStack {
                    ModListItem(summary: summary)
                    HStack(spacing: 25) {
                        MyButtonComponent(text: "转到 Modrinth", foregroundStyle: AppSettings.shared.theme.getTextStyle()) {
                            NSWorkspace.shared.open(summary.infoUrl)
                        }
                        .frame(width: 160, height: 40)
                        
                        MyButtonComponent(text: "复制名称") {
                            NSPasteboard.general.setString(summary.title, forType: .string)
                        }
                        .frame(width: 160, height: 40)
                        Spacer()
                    }
                }
                .padding(10)
            }
            .padding()
        }
        .scrollIndicators(.never)
        .onAppear {
            dataManager.leftTab(0) { EmptyView() }
        }
    }
}

