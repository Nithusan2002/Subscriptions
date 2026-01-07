//
//  SettingsView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var store: SubscriptionStore
    @AppStorage(AppDefaults.colorSchemePreference) private var colorSchemePreference = 0

    var body: some View {
        NavigationStack {
            List {
                Section("Utseende") {
                    Picker("Tema", selection: $colorSchemePreference) {
                        Text("System").tag(0)
                        Text("Lys").tag(1)
                        Text("Mørk").tag(2)
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    NavigationLink("Lås opp Pro") {
                        PaywallView()
                    }
                }

                Section(header: Text("Varsler"), footer: Text(notificationFooter)) {
                    Toggle("Varsler på denne enheten", isOn: Binding(
                        get: { store.notificationsEnabled },
                        set: { newValue in
                            if newValue {
                                store.notificationsEnabled = true
                                Task {
                                    _ = await store.requestNotificationPermission()
                                }
                            } else {
                                store.notificationsEnabled = false
                            }
                        }
                    ))

                    Picker("Standard varsel", selection: $store.defaultReminderOffsetDays) {
                        Text("Samme dag").tag(0)
                        Text("1 dag før").tag(1)
                        Text("2 dager før").tag(2)
                    }
                    .disabled(!store.notificationsEnabled)
                }

                Section("Mer") {
                    NavigationLink("Eksporter") {
                        ExportView()
                    }
                    NavigationLink("Om") {
                        AboutView()
                    }
                }
            }
            .navigationTitle("Innstillinger")
            .scrollContentBackground(.hidden)
        }
        .background(DesignTokens.appBackground.ignoresSafeArea())
    }

    private var notificationFooter: String {
        if store.notificationAuthorizationStatus == .denied {
            return "Varsler er slått av i iOS-innstillinger."
        }
        return "Standarden gjelder nye abonnementer."
    }
}

#Preview {
    SettingsView()
        .environmentObject(SubscriptionStore())
        .environmentObject(StoreKitManager())
}
