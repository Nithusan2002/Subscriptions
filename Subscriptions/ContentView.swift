//
//  ContentView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(AppDefaults.didShowIntro) private var didShowIntro = false
    @State private var showAddFromIntro = false

    var body: some View {
        RootView(showAddFromIntro: $showAddFromIntro)
            .fullScreenCover(isPresented: showIntro) {
                IntroView {
                    didShowIntro = true
                    showAddFromIntro = true
                }
            }
    }

    private var showIntro: Binding<Bool> {
        Binding(
            get: { !didShowIntro },
            set: { newValue in
                if newValue == false {
                    didShowIntro = true
                }
            }
        )
    }
}

#Preview {
    ContentView()
        .environmentObject(SubscriptionStore())
        .environmentObject(StoreKitManager())
}
