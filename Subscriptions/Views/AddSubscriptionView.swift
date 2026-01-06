//
//  AddSubscriptionView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct AddSubscriptionView: View {
    @EnvironmentObject var store: SubscriptionStore
    @Environment(\.dismiss) private var dismiss

    @State private var price: Double = 0
    @State private var nextChargeDate: Date = Date()
    @State private var selectedName: String? = nil
    @State private var customName: String = ""
    @State private var note: String = ""

    private let nameOptions = ["Netflix", "Spotify", "HBO Max", "Apple One", "Strim", "Viaplay", "Annet"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Obligatorisk") {
                    HStack {
                        Text("Pris per måned")
                        Spacer()
                        TextField("0", value: $price, format: .number.precision(.fractionLength(0)))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("kr")
                            .foregroundStyle(DesignTokens.subtleText)
                    }

                    DatePicker("Neste trekkdato", selection: $nextChargeDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "nb_NO"))
                }

                Section("Valgfritt") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(nameOptions, id: \.self) { option in
                                Button(action: { selectedName = option }) {
                                    Text(option)
                                        .font(DesignTokens.captionFont)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                }
                                .buttonStyle(.bordered)
                                .tint(selectedName == option ? .blue : .gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    if selectedName == "Annet" {
                        TextField("Skriv navn", text: $customName)
                    }

                    TextField("Notat (valgfritt)", text: $note)
                }
            }
            .navigationTitle("Nytt abonnement")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lagre") {
                        saveSubscription()
                        dismiss()
                    }
                    .disabled(price <= 0)
                }
            }
        }
    }

    private func saveSubscription() {
        let trimmedCustomName = customName.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedName: String?
        if selectedName == "Annet" {
            resolvedName = trimmedCustomName.isEmpty ? nil : trimmedCustomName
        } else {
            resolvedName = selectedName
        }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let reminder = store.notificationsEnabled ? store.defaultReminderOffsetDays : nil
        let subscription = Subscription(
            name: resolvedName,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            priceNOK: Decimal(price),
            nextChargeDate: nextChargeDate,
            reminderOffsetDays: reminder
        )
        store.add(subscription)
    }
}

#Preview {
    AddSubscriptionView()
        .environmentObject(SubscriptionStore())
}
