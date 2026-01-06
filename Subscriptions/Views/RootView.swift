//
//  RootView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
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
    RootView()
        .environmentObject(SubscriptionStore())
        .environmentObject(StoreKitManager())
}
