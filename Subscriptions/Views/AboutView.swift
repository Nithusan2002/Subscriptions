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
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        appIcon
                        Text("Abonnementer")
                            .font(DesignTokens.sectionTitleFont)
                        Text(appVersionText)
                            .font(DesignTokens.captionFont)
                            .foregroundStyle(DesignTokens.subtleText)
                    }

                    Text("En rolig oversikt over abonnementene dine, helt lokalt.")
                        .font(DesignTokens.bodyFont)
                        .foregroundStyle(DesignTokens.subtleText)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Personvern")
                            .font(DesignTokens.sectionTitleFont)
                        Text("Alle data lagres lokalt på enheten din og deles ikke med tredjepart.")
                            .font(DesignTokens.bodyFont)
                            .foregroundStyle(DesignTokens.subtleText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kontakt")
                            .font(DesignTokens.sectionTitleFont)
                        Link("Gi tilbakemelding", destination: supportURL)
                            .font(DesignTokens.bodyFont)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Juridisk")
                            .font(DesignTokens.sectionTitleFont)
                        Link("Personvernpolicy", destination: privacyURL)
                            .font(DesignTokens.bodyFont)
                        Link("Vilkår", destination: termsURL)
                            .font(DesignTokens.bodyFont)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(24)
            }
            .navigationTitle("Om")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") { dismiss() }
                }
            }
        }
        .background(DesignTokens.appBackground.ignoresSafeArea())
    }

    private var appIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(DesignTokens.cardBackground)
                .frame(width: 72, height: 72)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(DesignTokens.cardStroke)
                )
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(DesignTokens.accent)
        }
        .shadow(color: DesignTokens.cardShadow, radius: 8, x: 0, y: 4)
    }

    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Versjon \(version) (\(build))"
    }

    private var supportURL: URL {
        URL(string: "mailto:support@example.com")!
    }

    private var privacyURL: URL {
        URL(string: "https://example.com/personvern")!
    }

    private var termsURL: URL {
        URL(string: "https://example.com/vilkar")!
    }
}

#Preview {
    AboutView()
}
