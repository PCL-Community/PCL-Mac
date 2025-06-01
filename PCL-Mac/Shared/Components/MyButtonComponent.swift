//
//  ButtonComponent.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import SwiftUI

struct MyButtonComponent: View {
    let text: String
    var descriptionText: String? = nil
    var foregroundStyle: Color? = nil
    let action: () -> Void
    
    @State private var isHovered: Bool = false
    @State private var isPressed: Bool = false
    
    private func getForegroundStyle() -> Color {
        if let foregroundStyle = self.foregroundStyle {
            return foregroundStyle
        }
        return isHovered ? Color(hex: 0x1370F3) : Color(hex: 0x343D4A)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(self.getForegroundStyle(), lineWidth: 1.3)
                RoundedRectangle(cornerRadius: 6)
                    .foregroundStyle(Color(hex: 0xFFFFFF, alpha: isHovered ? 0.5 : 0.3))
                VStack {
                    Spacer()
                    Text(text)
                        .font(.custom("PCL English", size: 14))
                        .foregroundStyle(self.getForegroundStyle())
                    if let descriptionText = self.descriptionText {
                        Text(descriptionText)
                            .font(.custom("PCL English", size: 12))
                            .foregroundStyle(Color(hex: 0x9A9A9A))
                    }
                    Spacer()
                }
            }
            .onHover {
                isHovered = $0
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                    }
                    .onEnded { value in
                        if isPressed && geo.frame(in: .local).contains(value.location){
                            action()
                        }
                        isPressed = false
                    }
            )
            .scaleEffect(isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
        }
    }
}


#Preview {
    MyButtonComponent(text: "测试") { }
        .padding()
        .background(Color(hex: 0xC4CEE6))
}
