//
//  PaywallView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storeKit: StoreKitManager
    @State private var plan: Plan = .yearly
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(DesignTokens.accent)

                Text("Mer ro med Pro")
                    .font(DesignTokens.sectionTitleFont)

                Text("Hold oversikten uten grenser, fortsatt helt lokalt.")
                    .font(DesignTokens.bodyFont)
                    .foregroundStyle(DesignTokens.subtleText)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 10) {
                    Label("Ubegrenset antall abonnementer", systemImage: "checkmark.circle")
                    Label("Varsler og kontroll på alle", systemImage: "checkmark.circle")
                    Label("Støtter videre utvikling", systemImage: "checkmark.circle")
                }
                .font(DesignTokens.bodyFont)
                .foregroundStyle(Color.primary.opacity(0.85))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)

                Picker("Plan", selection: $plan) {
                    Text(monthlyLabel).tag(Plan.monthly)
                    Text(yearlyLabel).tag(Plan.yearly)
                }
                .pickerStyle(.segmented)

                Button(primaryButtonTitle) {
                    Task {
                        isPurchasing = true
                        let success = await purchaseSelectedPlan()
                        isPurchasing = false
                        if success {
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isPurchasing)

                Text("Kjøp administreres via App Store.")
                    .font(DesignTokens.captionFont)
                    .foregroundStyle(DesignTokens.subtleText)
            }
            .padding(24)
            .navigationTitle("Oppgrader")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lukk") { dismiss() }
                }
            }
        }
        .background(DesignTokens.appBackground.ignoresSafeArea())
        .task {
            await storeKit.loadProducts()
        }
    }

    private var primaryButtonTitle: String {
        switch plan {
        case .monthly:
            return "Oppgrader månedlig"
        case .yearly:
            return "Oppgrader årlig"
        }
    }

    private var monthlyLabel: String {
        if let product = storeKit.monthlyProduct {
            return "Månedlig \(product.displayPrice)"
        }
        return "Månedlig"
    }

    private var yearlyLabel: String {
        if let product = storeKit.yearlyProduct {
            return "Årlig \(product.displayPrice)"
        }
        return "Årlig"
    }

    private func purchaseSelectedPlan() async -> Bool {
        switch plan {
        case .monthly:
            if let product = storeKit.monthlyProduct {
                return await storeKit.purchase(product)
            }
        case .yearly:
            if let product = storeKit.yearlyProduct {
                return await storeKit.purchase(product)
            }
        }
        return false
    }
}

#Preview {
    PaywallView()
        .environmentObject(StoreKitManager())
}

private enum Plan: String {
    case monthly
    case yearly
}
