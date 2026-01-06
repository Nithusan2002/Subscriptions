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
    @Published private(set) var subscriptions: [Subscription] = []
    @Published private(set) var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
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

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.storageURL = documents.appendingPathComponent("subscriptions.json")
        let storedEnabled = UserDefaults.standard.object(forKey: DefaultsKey.notificationsEnabled) as? Bool
        self.notificationsEnabled = storedEnabled ?? true
        let storedOffset = UserDefaults.standard.object(forKey: DefaultsKey.defaultReminderOffsetDays) as? Int
        self.defaultReminderOffsetDays = storedOffset ?? 1
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
        subscriptions.append(subscription)
        save()
        scheduleIfAllowed(for: subscription)
    }

    func update(_ subscription: Subscription) {
        guard let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) else { return }
        var updated = subscription
        updated.updatedAt = Date()
        subscriptions[index] = updated
        save()
        scheduleIfAllowed(for: updated)
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
}

private enum DefaultsKey {
    static let notificationsEnabled = "notificationsEnabled"
    static let defaultReminderOffsetDays = "defaultReminderOffsetDays"
}
