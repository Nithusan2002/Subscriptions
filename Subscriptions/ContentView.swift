//
//  ContentView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
         RootView()
    }
}

#Preview {
    ContentView()
        .environmentObject(SubscriptionStore())
}
