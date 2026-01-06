//
//  Subscription.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import Foundation

struct Subscription: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String?
    var note: String?
    var priceNOK: Decimal
    var nextChargeDate: Date

    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    // Future-ready (skjult i UI)
    var billingCycle: BillingCycle
    var currency: String
    var reminderOffsetDays: Int?
    var lastNotifiedAt: Date?

    init(
        id: UUID = UUID(),
        name: String? = nil,
        note: String? = nil,
        priceNOK: Decimal,
        nextChargeDate: Date,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        billingCycle: BillingCycle = .monthly,
        currency: String = "NOK",
        reminderOffsetDays: Int? = 1,
        lastNotifiedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.note = note
        self.priceNOK = priceNOK
        self.nextChargeDate = nextChargeDate
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.billingCycle = billingCycle
        self.currency = currency
        self.reminderOffsetDays = reminderOffsetDays
        self.lastNotifiedAt = lastNotifiedAt
    }
}

enum BillingCycle: String, Codable {
    case monthly
}

struct MonthlySnapshot: Codable, Equatable {
    var year: Int
    var month: Int
    var totalPerMonth: Decimal
}
