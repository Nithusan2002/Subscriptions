//
//  HomeView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: SubscriptionStore

    @State private var isPresentingAdd = false
    @State private var selectedSubscription: Subscription? = nil
    @AppStorage("didShowNotificationPrompt") private var didShowNotificationPrompt = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.sectionSpacing) {
                    if store.activeSubscriptions.isEmpty {
                        EmptyStateView(onAdd: { isPresentingAdd = true })
                    } else {
                        heroSection
                        if shouldShowNotificationPrompt {
                            NotificationInlinePromptView(
                                onEnable: requestNotifications,
                                onDismiss: { didShowNotificationPrompt = true }
                            )
                        }
                        subscriptionsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .navigationTitle("Oversikt")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { isPresentingAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAdd) {
                AddSubscriptionView()
                    .environmentObject(store)
            }
            .sheet(item: $selectedSubscription) { subscription in
                EditSubscriptionView(subscription: subscription)
                    .environmentObject(store)
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 8) {
            Text("\(Formatters.nokString(store.totalPerMonth)) kr / mnd")
                .font(DesignTokens.heroFont)
            Text("≈ \(Formatters.nokString(store.annualEstimate)) kr per år")
                .font(DesignTokens.heroSubFont)
                .foregroundStyle(DesignTokens.subtleText)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .multilineTextAlignment(.center)
    }

    private var subscriptionsSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(store.activeSorted) { subscription in
                Button(action: { selectedSubscription = subscription }) {
                    SubscriptionCardView(subscription: subscription)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var shouldShowNotificationPrompt: Bool {
        !didShowNotificationPrompt
        && store.notificationsEnabled
        && !store.hasNotificationAuthorization
        && !store.activeSubscriptions.isEmpty
    }

    private func requestNotifications() {
        Task {
            _ = await store.requestNotificationPermission()
            didShowNotificationPrompt = true
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(SubscriptionStore())
}
