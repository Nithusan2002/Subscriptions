//
//  Formatters.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import Foundation

enum Formatters {
    static let nokNumber: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func nokString(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        return nokNumber.string(from: number) ?? "0"
    }

    static let dateShort: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.dateFormat = "dd.MM"
        return formatter
    }()

    static let dateFull: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.dateStyle = .medium
        return formatter
    }()

    static let dateShortMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.dateFormat = "d. MMM"
        return formatter
    }()
}
