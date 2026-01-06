//
//  AboutView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "rectangle.stack.fill")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(DesignTokens.accent)

                Text("Abonnementer")
                    .font(DesignTokens.sectionTitleFont)

                Text("En rolig oversikt over abonnementene dine, helt lokalt.\nKontroll, oversikt og ro.")
                    .font(DesignTokens.bodyFont)
                    .foregroundStyle(DesignTokens.subtleText)
                    .multilineTextAlignment(.center)

                Text(appVersionText)
                    .font(DesignTokens.captionFont)
                    .foregroundStyle(DesignTokens.subtleText)
            }
            .padding(24)
            .navigationTitle("Om")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") { dismiss() }
                }
            }
        }
        .background(DesignTokens.appBackground.ignoresSafeArea())
    }

    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Versjon \(version) (\(build))"
    }
}

#Preview {
    AboutView()
}
