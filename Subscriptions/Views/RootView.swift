//
//  RootView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct RootView: View {
    @Binding var showAddFromIntro: Bool
    @AppStorage(AppDefaults.colorSchemePreference) private var colorSchemePreference = 0

    var body: some View {
        TabView {
            HomeView(showAddFromIntro: $showAddFromIntro)
                .tabItem {
                    Label("Oversikt", systemImage: "rectangle.stack")
                }

            SettingsView()
                .tabItem {
                    Label("Innstillinger", systemImage: "gearshape")
                }
        }
        .tint(DesignTokens.accent)
        .preferredColorScheme(preferredColorScheme)
    }

    private var preferredColorScheme: ColorScheme? {
        switch colorSchemePreference {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil
        }
    }
}

#Preview {
    RootView(showAddFromIntro: .constant(false))
        .environmentObject(SubscriptionStore())
        .environmentObject(StoreKitManager())
}
