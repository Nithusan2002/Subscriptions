//
//  EditSubscriptionView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct EditSubscriptionView: View {
    @EnvironmentObject var store: SubscriptionStore
    @Environment(\.dismiss) private var dismiss

    @State private var price: Double
    @State private var nextChargeDate: Date
    @State private var selectedName: String?
    @State private var customName: String
    @State private var note: String
    @State private var isActive: Bool
    @State private var notificationsEnabled: Bool
    @State private var reminderOffsetDays: Int

    private let subscriptionID: UUID
    private let nameOptions = ["Netflix", "Spotify", "HBO Max", "Apple One", "Strim", "Viaplay", "Annet"]

    init(subscription: Subscription) {
        subscriptionID = subscription.id
        _price = State(initialValue: NSDecimalNumber(decimal: subscription.priceNOK).doubleValue)
        _nextChargeDate = State(initialValue: subscription.nextChargeDate)
        if let name = subscription.name, nameOptions.contains(name) {
            _selectedName = State(initialValue: name)
            _customName = State(initialValue: "")
        } else if let name = subscription.name, !name.isEmpty {
            _selectedName = State(initialValue: "Annet")
            _customName = State(initialValue: name)
        } else {
            _selectedName = State(initialValue: nil)
            _customName = State(initialValue: "")
        }
        _note = State(initialValue: subscription.note ?? "")
        _isActive = State(initialValue: subscription.isActive)
        _notificationsEnabled = State(initialValue: subscription.reminderOffsetDays != nil)
        _reminderOffsetDays = State(initialValue: subscription.reminderOffsetDays ?? 1)
    }

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

                Section("Varsler", footer: Text(footerText)) {
                    Toggle("Varsle om trekk", isOn: $notificationsEnabled)
                    if notificationsEnabled {
                        Picker("Tidspunkt", selection: $reminderOffsetDays) {
                            Text("Samme dag").tag(0)
                            Text("1 dag før").tag(1)
                            Text("2 dager før").tag(2)
                        }
                    }
                }
                .disabled(!store.notificationsEnabled)

                Section {
                    Toggle("Avsluttet", isOn: Binding(
                        get: { !isActive },
                        set: { isActive = !$0 }
                    ))
                }
            }
            .navigationTitle("Abonnement")
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
        let reminder = (store.notificationsEnabled && notificationsEnabled) ? reminderOffsetDays : nil

        guard let existing = store.subscription(with: subscriptionID) else { return }

        let updated = Subscription(
            id: existing.id,
            name: resolvedName,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            priceNOK: Decimal(price),
            nextChargeDate: nextChargeDate,
            isActive: isActive,
            createdAt: existing.createdAt,
            updatedAt: Date(),
            billingCycle: existing.billingCycle,
            currency: existing.currency,
            reminderOffsetDays: reminder,
            lastNotifiedAt: existing.lastNotifiedAt
        )
        store.update(updated)
    }

    private var footerText: String {
        store.notificationsEnabled ? "" : "Varsler er slått av i Innstillinger."
    }
}

#Preview {
    EditSubscriptionView(subscription: Subscription(priceNOK: 99, nextChargeDate: Date()))
        .environmentObject(SubscriptionStore())
}
