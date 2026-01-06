//
//  PaywallView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.tint)

                Text("Oppgrader for flere")
                    .font(DesignTokens.sectionTitleFont)

                Text("Du kan legge til opptil 3 abonnementer gratis.\nOppgrader for full oversikt uten begrensninger.")
                    .font(DesignTokens.bodyFont)
                    .foregroundStyle(DesignTokens.subtleText)
                    .multilineTextAlignment(.center)

                Button("Oppgrader") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

                Button("Ikke nå") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding(24)
            .navigationTitle("Oppgrader")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    PaywallView()
}
