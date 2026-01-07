//
//  RootView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct RootView: View {
    @Binding var showAddFromIntro: Bool

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
    }
}

#Preview {
    RootView(showAddFromIntro: .constant(false))
        .environmentObject(SubscriptionStore())
        .environmentObject(StoreKitManager())
}
