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
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Spacer()
                Text("\(Formatters.nokString(subscription.priceNOK)) kr/mnd")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
            }
            Text("Neste trekk \(Formatters.dateShortMonth.string(from: subscription.nextChargeDate))")
                .font(DesignTokens.captionFont)
                .foregroundStyle(Color.secondary)
                .padding(.top, 2)
            if let note = trimmedNote, !note.isEmpty {
                Text(note)
                    .font(DesignTokens.captionFont)
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
            }
        }
        .padding(DesignTokens.cardPadding)
        .background(DesignTokens.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius)
                .stroke(DesignTokens.cardStroke)
        )
        .shadow(color: DesignTokens.cardShadow, radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(displayName)
        .accessibilityValue(accessibilityValue)
    }

    private var displayName: String {
        let trimmed = subscription.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed! : "Abonnement"
    }

    private var trimmedNote: String? {
        subscription.note?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var accessibilityValue: String {
        var parts = [
            "\(Formatters.nokString(subscription.priceNOK)) kroner per måned",
            "Neste trekk \(Formatters.dateShortMonth.string(from: subscription.nextChargeDate))"
        ]
        if let note = trimmedNote, !note.isEmpty {
            parts.append("Notat: \(note)")
        }
        return parts.joined(separator: ". ")
    }
}

#Preview {
    SubscriptionCardView(subscription: Subscription(priceNOK: 129, nextChargeDate: Date()))
        .padding()
}
