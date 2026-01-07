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
    @Binding var showAddFromIntro: Bool

    init(showAddFromIntro: Binding<Bool> = .constant(false)) {
        _showAddFromIntro = showAddFromIntro
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.sectionSpacing) {
                    if store.isLoading {
                        loadingSection
                    } else if store.activeSubscriptions.isEmpty {
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
            .overlay(alignment: .top) {
                if let message = store.feedbackMessage {
                    FeedbackToastView(message: message)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: store.feedbackMessage)
            .toolbar {
                if !store.activeSubscriptions.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { isPresentingAdd = true }) {
                            Image(systemName: "plus")
                        }
                        .tint(DesignTokens.accent)
                        .opacity(0.9)
                        .accessibilityLabel("Legg til abonnement")
                        .accessibilityHint("Åpner nytt abonnement")
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
        .background(DesignTokens.appBackground.ignoresSafeArea())
        .onChange(of: showAddFromIntro) { _, newValue in
            if newValue {
                isPresentingAdd = true
                showAddFromIntro = false
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 8) {
            Text("\(Formatters.nokString(store.totalPerMonth)) kr / mnd")
                .font(DesignTokens.heroFont)
            Text("≈ \(Formatters.nokString(store.annualEstimate)) kr per år")
                .font(DesignTokens.captionFont)
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .background(DesignTokens.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.cardCornerRadius)
                .stroke(DesignTokens.cardStroke)
        )
        .shadow(color: DesignTokens.cardShadow, radius: 10, x: 0, y: 4)
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

    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
                .accessibilityLabel("Laster oversikt")
            Text("Henter oversikt…")
                .font(DesignTokens.captionFont)
                .foregroundStyle(DesignTokens.subtleText)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 40)
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
