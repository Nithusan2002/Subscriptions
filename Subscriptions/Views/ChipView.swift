//
//  ChipView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct ChipButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let accessibilityHint: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(DesignTokens.captionFont)
            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.accentColor.opacity(0.12))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.accentColor.opacity(isSelected ? 0.25 : 0), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(accessibilityHint ?? "")
    }
}

#Preview {
    VStack(spacing: 12) {
        ChipButton(title: "Netflix", systemImage: "play.circle.fill", isSelected: false, accessibilityHint: "Velg abonnement", action: {})
        ChipButton(title: "Netflix", systemImage: "play.circle.fill", isSelected: true, accessibilityHint: "Velg abonnement", action: {})
    }
    .padding()
}
