//
//  NotificationInlinePromptView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct NotificationInlinePromptView: View {
    let onEnable: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vil du få et rolig varsel før neste trekk?")
                .font(DesignTokens.bodyFont)
            HStack {
                Button(action: onEnable) {
                    Text("Slå på varsler")
                }
                .buttonStyle(.borderedProminent)
                Button(action: onDismiss) {
                    Text("Ikke nå")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(DesignTokens.cardPadding)
        .background(DesignTokens.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
    }
}

#Preview {
    NotificationInlinePromptView(onEnable: {}, onDismiss: {})
        .padding()
}
