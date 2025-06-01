//
//  Theme.swift
//  PCL-Mac
//
//  Created by YiZhiMCQiu on 2025/5/30.
//

import SwiftUI

public enum Theme: String, CaseIterable {
    case pcl, colorful
    
    public func getGradientView() -> some ShapeStyle {
        switch self {
        case .colorful:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 255 / 255, green: 172 / 255, blue: 40 / 255),
                        Color(red: 255 / 255, green: 55 / 255, blue: 105 / 255),
                        Color(red: 210 / 255, green: 156 / 255, blue: 255 / 255),
                        Color(red: 138 / 255, green: 207 / 255, blue: 234 / 255)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .pcl:
            return AnyShapeStyle(
                RadialGradient(
                    gradient: Gradient(colors: [Color(hex: 0x1177DC), Color(hex: 0x0F6AC4)]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 410
                )
            )
        }
    }
    
    public func gradientOr(_ color: Color) -> some ShapeStyle {
        if self == .colorful {
            return AnyShapeStyle(getGradientView())
        }
        return AnyShapeStyle(color)
    }
}
