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
    @State private var activeSheet: HomeSheet? = nil
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
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Innstillinger") { activeSheet = .settings }
                        Button("Eksporter") { activeSheet = .export }
                        Button("Om") { activeSheet = .about }
                    } label: {
                        Image(systemName: "ellipsis.circle")
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
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .about:
                    AboutView()
                case .settings, .export:
                    InfoSheetView(title: sheet.title, message: sheet.message)
                }
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
        !didShowNotificationPrompt && !store.hasNotificationAuthorization && !store.activeSubscriptions.isEmpty
    }

    private func requestNotifications() {
        Task {
            _ = await store.requestNotificationPermission()
            didShowNotificationPrompt = true
        }
    }
}

private enum HomeSheet: String, Identifiable {
    case settings
    case export
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .settings:
            return "Innstillinger"
        case .export:
            return "Eksporter"
        case .about:
            return "Om"
        }
    }

    var message: String {
        switch self {
        case .settings:
            return "Kommer snart. Vi holder dette enkelt og rolig i MVP."
        case .export:
            return "Kommer snart. Eksport er planlagt, men ikke i MVP."
        case .about:
            return "En rolig oversikt over abonnementene dine, helt lokalt.\nKontroll, oversikt og ro."
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(SubscriptionStore())
}
