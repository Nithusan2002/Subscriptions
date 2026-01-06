//
//  SubscriptionCardView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct SubscriptionCardView: View {
    let subscription: Subscription

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(displayName)
                    .font(DesignTokens.sectionTitleFont)
                Spacer()
                Text("\(Formatters.nokString(subscription.priceNOK)) kr/mnd")
                    .font(DesignTokens.bodyFont)
            }
            Text("Neste trekk: \(Formatters.dateShort.string(from: subscription.nextChargeDate))")
                .font(DesignTokens.captionFont)
                .foregroundStyle(DesignTokens.subtleText)
        }
        .padding(DesignTokens.cardPadding)
        .background(DesignTokens.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius)
                .stroke(DesignTokens.cardStroke)
        )
        .shadow(color: DesignTokens.cardShadow, radius: 10, x: 0, y: 4)
    }

    private var displayName: String {
        let trimmed = subscription.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed! : "Abonnement"
    }
}

#Preview {
    SubscriptionCardView(subscription: Subscription(priceNOK: 129, nextChargeDate: Date()))
        .padding()
}
