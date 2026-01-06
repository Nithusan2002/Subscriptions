//
//  FeedbackToastView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct FeedbackToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(DesignTokens.captionFont)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 16)
    }
}

#Preview {
    FeedbackToastView(message: "Du sparer 129 kr/mnd 🎉")
}
