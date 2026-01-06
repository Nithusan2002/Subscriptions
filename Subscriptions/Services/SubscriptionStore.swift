//
//  SubscriptionStore.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import Foundation
import UserNotifications
internal import Combine

@MainActor
final class SubscriptionStore: ObservableObject {
    static let maxFreeSubscriptions = 3

    @Published private(set) var subscriptions: [Subscription] = []
    @Published private(set) var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var feedbackMessage: String? = nil
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: DefaultsKey.notificationsEnabled)
            if !notificationsEnabled {
                notificationCenter.removeAllPendingNotificationRequests()
            } else if hasNotificationAuthorization {
                scheduleAll()
            }
        }
    }
    @Published var defaultReminderOffsetDays: Int {
        didSet {
            UserDefaults.standard.set(defaultReminderOffsetDays, forKey: DefaultsKey.defaultReminderOffsetDays)
        }
    }

    private let storageURL: URL
    private let notificationCenter = UNUserNotificationCenter.current()
    private var monthlySnapshots: [MonthlySnapshot] = []

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.storageURL = documents.appendingPathComponent("subscriptions.json")
        let storedEnabled = UserDefaults.standard.object(forKey: DefaultsKey.notificationsEnabled) as? Bool
        self.notificationsEnabled = storedEnabled ?? true
        let storedOffset = UserDefaults.standard.object(forKey: DefaultsKey.defaultReminderOffsetDays) as? Int
        self.defaultReminderOffsetDays = storedOffset ?? 1
        loadMonthlySnapshots()
        load()
        Task {
            await refreshAuthorizationStatus()
        }
    }

    var activeSubscriptions: [Subscription] {
        subscriptions.filter { $0.isActive }
    }

    var activeSorted: [Subscription] {
        activeSubscriptions.sorted { $0.nextChargeDate < $1.nextChargeDate }
    }

    var totalPerMonth: Decimal {
        activeSubscriptions.reduce(Decimal(0)) { $0 + $1.priceNOK }
    }

    var freeLimitReached: Bool {
        activeSubscriptions.count >= Self.maxFreeSubscriptions
    }

    var annualEstimate: Decimal {
        totalPerMonth * Decimal(12)
    }

    var hasNotificationAuthorization: Bool {
        notificationAuthorizationStatus == .authorized || notificationAuthorizationStatus == .provisional
    }

    func subscription(with id: UUID) -> Subscription? {
        subscriptions.first(where: { $0.id == id })
    }

    func add(_ subscription: Subscription) {
        let previousTotal = totalPerMonth
        subscriptions.append(subscription)
        save()
        scheduleIfAllowed(for: subscription)
        let currentTotal = totalPerMonth
        updateMonthlySnapshot(total: currentTotal)
        maybeShowMonthlyInsight(currentTotal: currentTotal, previousTotal: previousTotal)
    }

    func update(_ subscription: Subscription) {
        guard let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) else { return }
        let previousTotal = totalPerMonth
        let previous = subscriptions[index]
        var updated = subscription
        updated.updatedAt = Date()
        subscriptions[index] = updated
        save()
        scheduleIfAllowed(for: updated)

        if previous.isActive && !updated.isActive {
            let savings = Formatters.nokString(previous.priceNOK)
            showFeedback("Du sparer \(savings) kr/mnd 🎉")
        }

        let currentTotal = totalPerMonth
        updateMonthlySnapshot(total: currentTotal)
        maybeShowMonthlyInsight(currentTotal: currentTotal, previousTotal: previousTotal)
    }

    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
            await refreshAuthorizationStatus()
            notificationsEnabled = granted
            if granted {
                scheduleAll()
            }
            return granted
        } catch {
            return false
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        notificationAuthorizationStatus = settings.authorizationStatus
    }

    func scheduleAll() {
        notificationCenter.removeAllPendingNotificationRequests()
        for subscription in activeSubscriptions {
            scheduleNotification(for: subscription)
        }
    }

    func removeNotification(for subscriptionID: UUID) {
        let identifier = notificationIdentifier(for: subscriptionID)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    private func scheduleIfAllowed(for subscription: Subscription) {
        guard notificationsEnabled, hasNotificationAuthorization else { return }
        scheduleNotification(for: subscription)
    }

    private func scheduleNotification(for subscription: Subscription) {
        removeNotification(for: subscription.id)
        guard subscription.isActive else { return }
        guard let offset = subscription.reminderOffsetDays else { return }
        guard let triggerDate = Calendar.current.date(byAdding: .day, value: -offset, to: subscription.nextChargeDate) else { return }
        guard triggerDate > Date() else { return }

        let name = subscription.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = name?.isEmpty == false ? name! : "Abonnement"
        let price = Formatters.nokString(subscription.priceNOK)

        let prefix: String
        if offset == 0 {
            prefix = "Trekk i dag"
        } else if offset == 1 {
            prefix = "Trekk i morgen"
        } else {
            prefix = "Trekk snart"
        }

        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = "\(prefix): \(displayName) – \(price) kr"
        content.sound = .default

        var components = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        components.hour = 9
        components.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: notificationIdentifier(for: subscription.id), content: content, trigger: trigger)
        notificationCenter.add(request)
    }

    private func notificationIdentifier(for subscriptionID: UUID) -> String {
        "subscription-\(subscriptionID.uuidString)"
    }

    private func load() {
        guard let data = try? Data(contentsOf: storageURL) else { return }
        do {
            let decoded = try JSONDecoder().decode([Subscription].self, from: data)
            subscriptions = decoded
        } catch {
            subscriptions = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(subscriptions)
            try data.write(to: storageURL, options: [.atomic])
        } catch {
            return
        }
    }

    private func updateMonthlySnapshot(total: Decimal) {
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        guard let year = components.year, let month = components.month else { return }
        if let index = monthlySnapshots.firstIndex(where: { $0.year == year && $0.month == month }) {
            monthlySnapshots[index].totalPerMonth = total
        } else {
            monthlySnapshots.append(MonthlySnapshot(year: year, month: month, totalPerMonth: total))
        }
        saveMonthlySnapshots()
    }

    private func maybeShowMonthlyInsight(currentTotal: Decimal, previousTotal: Decimal) {
        guard currentTotal < previousTotal else { return }
        guard let previousSnapshot = previousMonthSnapshot() else { return }
        guard previousSnapshot.totalPerMonth > 0 else { return }
        guard currentTotal < previousSnapshot.totalPerMonth else { return }

        let percentage = 1 - (currentTotal / previousSnapshot.totalPerMonth)
        let percentInt = Int((percentage * Decimal(100)).rounded())
        guard percentInt > 0 else { return }

        let monthKey = currentMonthKey()
        let lastShown = UserDefaults.standard.string(forKey: DefaultsKey.lastMonthlyInsightShown)
        guard lastShown != monthKey else { return }

        showFeedback("Faste kostnader ↓ \(percentInt) % siden forrige måned")
        UserDefaults.standard.set(monthKey, forKey: DefaultsKey.lastMonthlyInsightShown)
    }

    private func currentMonthKey() -> String {
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        let year = components.year ?? 0
        let month = components.month ?? 0
        return "\(year)-\(month)"
    }

    private func previousMonthSnapshot() -> MonthlySnapshot? {
        guard let date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) else { return nil }
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        guard let year = components.year, let month = components.month else { return nil }
        return monthlySnapshots.first(where: { $0.year == year && $0.month == month })
    }

    private func loadMonthlySnapshots() {
        guard let data = UserDefaults.standard.data(forKey: DefaultsKey.monthlySnapshots) else { return }
        if let decoded = try? JSONDecoder().decode([MonthlySnapshot].self, from: data) {
            monthlySnapshots = decoded
        }
    }

    private func saveMonthlySnapshots() {
        if let data = try? JSONEncoder().encode(monthlySnapshots) {
            UserDefaults.standard.set(data, forKey: DefaultsKey.monthlySnapshots)
        }
    }

    private func showFeedback(_ message: String) {
        feedbackMessage = message
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            if feedbackMessage == message {
                feedbackMessage = nil
            }
        }
    }
}

private enum DefaultsKey {
    static let notificationsEnabled = "notificationsEnabled"
    static let defaultReminderOffsetDays = "defaultReminderOffsetDays"
    static let monthlySnapshots = "monthlySnapshots"
    static let lastMonthlyInsightShown = "lastMonthlyInsightShown"
}
