//
//  DesignTokens.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

enum DesignTokens {
    static let heroFont = Font.system(size: 40, weight: .semibold, design: .rounded)
    static let heroSubFont = Font.system(size: 16, weight: .regular, design: .rounded)
    static let sectionTitleFont = Font.system(size: 18, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 13, weight: .regular, design: .rounded)

    static let cardCornerRadius: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 20

    static let cardBackground = Color(.secondarySystemBackground)
    static let subtleText = Color(.secondaryLabel)
}
