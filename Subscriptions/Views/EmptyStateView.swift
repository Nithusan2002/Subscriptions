//
//  EmptyStateView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct EmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Du har full kontroll.\nNår du legger til abonnementer, ser du nøyaktig hva de koster deg.")
                .font(DesignTokens.bodyFont)
                .foregroundStyle(DesignTokens.subtleText)
                .multilineTextAlignment(.center)
            Button(action: onAdd) {
                Text("Legg til abonnement")
                    .font(DesignTokens.bodyFont)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }
}

#Preview {
    EmptyStateView(onAdd: {})
}
