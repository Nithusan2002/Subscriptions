//
//  IntroView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct IntroView: View {
    let onPrimary: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Ro og oversikt over abonnementene dine, på sekunder.")
                .font(DesignTokens.sectionTitleFont)
                .multilineTextAlignment(.center)

            previewCard
                .padding(.horizontal, 24)

            Button(action: onPrimary) {
                Text("Legg til første abonnement")
                    .font(DesignTokens.bodyFont)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding(.vertical, 24)
        .background(DesignTokens.appBackground.ignoresSafeArea())
    }

    private var previewCard: some View {
        VStack(spacing: 6) {
            Text("Eksempel")
                .font(DesignTokens.captionFont)
                .foregroundStyle(DesignTokens.subtleText)
            Text("1 249 kr / mnd")
                .font(DesignTokens.sectionTitleFont)
            Text("≈ 14 988 kr per år")
                .font(DesignTokens.captionFont)
                .foregroundStyle(DesignTokens.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignTokens.cardPadding)
        .background(DesignTokens.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius)
                .stroke(DesignTokens.cardStroke)
        )
        .shadow(color: DesignTokens.cardShadow, radius: 10, x: 0, y: 4)
    }
}

#Preview {
    IntroView(onPrimary: {})
}
