//
//  WindowControlButton.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/17.
//

import SwiftUI

struct WindowControlButton: View {
    static let Close: WindowControlButton = WindowControlButton(systemName: "xmark") {
        NSApplication.shared.terminate(nil)
    }
    static let Miniaturize: WindowControlButton = WindowControlButton(systemName: "minus") {
        NSApplication.shared.windows.first!.miniaturize(nil)
    }
    let systemName: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        VStack {
            Image(systemName: systemName)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 13)
                .foregroundStyle(.white)
                .bold()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isHovered ? Color(hex: 0xFFFFFF, alpha: 0.17) : Color.clear)
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                        .frame(width: 30, height: 30)
                )
        }
        .frame(width: 30, height: 30)
        .onHover { hover in
            isHovered = hover
        }
        .onTapGesture(perform: action)
    }
}
