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

    @State private var priceText: String
    @State private var nextChargeDate: Date
    @State private var selectedName: String?
    @State private var customName: String
    @State private var note: String
    @State private var isActive: Bool
    @State private var notificationsEnabled: Bool
    @State private var reminderOffsetDays: Int

    private let subscriptionID: UUID
    private let popularOptions: [ChipOption] = [
        ChipOption(title: "Netflix", systemImage: "play.circle.fill"),
        ChipOption(title: "Spotify", systemImage: "play.circle.fill"),
        ChipOption(title: "Strim", systemImage: "play.circle.fill"),
        ChipOption(title: "Amazon Prime", systemImage: "play.circle.fill"),
        ChipOption(title: "Viaplay", systemImage: "play.circle.fill"),
        ChipOption(title: "Disney+", systemImage: "play.circle.fill")
    ]
    private let otherOptions: [ChipOption] = [
        ChipOption(title: "Annet", systemImage: "square.and.pencil")
    ]

    init(subscription: Subscription) {
        subscriptionID = subscription.id
        _priceText = State(initialValue: Formatters.nokString(subscription.priceNOK))
        _nextChargeDate = State(initialValue: subscription.nextChargeDate)
        let allOptions = popularOptions.map { $0.title } + otherOptions.map { $0.title }
        if let name = subscription.name, allOptions.contains(name) {
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
            List {
                requiredSection
                optionalSection
                notificationSection
                statusSection
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
                    .disabled((parsedPrice ?? 0) <= 0)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(DesignTokens.appBackground.ignoresSafeArea())
    }

    private func saveSubscription() {
        guard let price = parsedPrice, price > 0 else { return }
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
            priceNOK: price,
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

    private var requiredSection: some View {
        Section("Obligatorisk") {
            HStack {
                Text("Pris per måned")
                Spacer()
                TextField("0", text: $priceText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("Pris per måned i kroner")
                Text("kr")
                    .foregroundStyle(DesignTokens.subtleText)
                    .accessibilityHidden(true)
            }
            .onChange(of: priceText) { _, newValue in
                priceText = formattedDigits(from: newValue)
            }

            DatePicker("Neste trekkdato", selection: $nextChargeDate, displayedComponents: .date)
                .environment(\.locale, Locale(identifier: "nb_NO"))
        }
    }

    private var optionalSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(popularOptions, id: \.title) { option in
                        ChipButton(
                            title: option.title,
                            systemImage: option.systemImage,
                            isSelected: selectedName == option.title,
                            accessibilityHint: "Velg hurtignavn",
                            action: { selectedName = option.title }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(otherOptions, id: \.title) { option in
                        ChipButton(
                            title: option.title,
                            systemImage: option.systemImage,
                            isSelected: selectedName == option.title,
                            accessibilityHint: "Åpner fritekstfelt",
                            action: { selectedName = option.title }
                        )
                    }
                }
                .padding(.vertical, 4)
            }

            if selectedName == "Annet" {
                TextField("Skriv navn", text: $customName)
            }

            TextField("Notat (valgfritt)", text: $note)
                .onChange(of: note) { _, newValue in
                    if newValue.count > 30 {
                        note = String(newValue.prefix(30))
                    }
                }
                .accessibilityHint("Vises på abonnementskortet")
        }
    }

    private var notificationSection: some View {
        Section(header: Text("Varsler"), footer: Text(footerText)) {
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
    }

    private var statusSection: some View {
        Section {
            Toggle("Avsluttet", isOn: Binding(
                get: { !isActive },
                set: { isActive = !$0 }
            ))
        }
    }

    private var parsedPrice: Decimal? {
        let digits = priceText.replacingOccurrences(of: " ", with: "")
        guard !digits.isEmpty else { return nil }
        return Decimal(string: digits)
    }

    private func formattedDigits(from input: String) -> String {
        let digits = input.filter { $0.isNumber }
        guard !digits.isEmpty else { return "" }
        let number = NSDecimalNumber(string: digits)
        return Formatters.nokNumber.string(from: number) ?? digits
    }
}

private struct ChipOption {
    let title: String
    let systemImage: String
}

#Preview {
    EditSubscriptionView(subscription: Subscription(priceNOK: 99, nextChargeDate: Date()))
        .environmentObject(SubscriptionStore())
}
