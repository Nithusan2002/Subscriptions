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
    @FocusState private var isCustomNameFocused: Bool

    @State private var priceText: String = ""
    @State private var nextChargeDate: Date = Date()
    @State private var selectedName: String? = nil
    @State private var customName: String = ""
    @State private var note: String = ""
    @State private var isPresentingPaywall = false

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

    var body: some View {
        NavigationStack {
            Form {
                Section("Obligatorisk") {
                    HStack {
                        Text("Pris per måned")
                        Spacer()
                        TextField("129", text: $priceText)
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
                        .listRowSeparator(.hidden)

                    HStack(spacing: 12) {
                        Button("I dag") {
                            nextChargeDate = Date()
                        }
                        .buttonStyle(.bordered)
                        .accessibilityLabel("Sett trekkdato til i dag")

                        Button("Neste måned") {
                            nextChargeDate = nextMonthDate(from: Date())
                        }
                        .buttonStyle(.bordered)
                        .accessibilityLabel("Sett trekkdato til neste måned")
                    }
                }

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
                        .padding(.vertical, 8)
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
                        .padding(.vertical, 8)
                    }

                    if selectedName == "Annet" {
                        TextField("Skriv navn", text: $customName)
                            .focused($isCustomNameFocused)
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
            .navigationTitle("Nytt abonnement")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lagre") {
                        if store.freeLimitReached {
                            isPresentingPaywall = true
                        } else {
                            saveSubscription()
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            dismiss()
                        }
                    }
                    .disabled((parsedPrice ?? 0) <= 0)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(DesignTokens.appBackground.ignoresSafeArea())
        .sheet(isPresented: $isPresentingPaywall) {
            PaywallView()
        }
        .onChange(of: selectedName) { _, newValue in
            isCustomNameFocused = newValue == "Annet"
        }
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
        let reminder = store.notificationsEnabled ? store.defaultReminderOffsetDays : nil
        let subscription = Subscription(
            name: resolvedName,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            priceNOK: price,
            nextChargeDate: nextChargeDate,
            reminderOffsetDays: reminder
        )
        store.add(subscription)
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

    private func nextMonthDate(from date: Date) -> Date {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        var components = calendar.dateComponents([.year, .month], from: date)
        components.month = (components.month ?? 1) + 1
        components.day = 1
        guard let startOfNextMonth = calendar.date(from: components) else { return date }

        let range = calendar.range(of: .day, in: .month, for: startOfNextMonth) ?? 1..<31
        let clampedDay = min(day, range.count)
        return calendar.date(bySetting: .day, value: clampedDay, of: startOfNextMonth) ?? startOfNextMonth
    }
}

private struct ChipOption {
    let title: String
    let systemImage: String
}

#Preview {
    AddSubscriptionView()
        .environmentObject(SubscriptionStore())
}
