//
//  SubscriptionsApp.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

@main
struct SubscriptionsApp: App {
    @StateObject private var store = SubscriptionStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
