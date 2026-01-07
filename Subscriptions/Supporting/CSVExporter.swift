//
//  CSVExporter.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import Foundation

enum CSVExporter {
    static func subscriptionsCSV(subscriptions: [Subscription], delimiter: CSVDelimiter) -> String {
        let d = delimiter.rawValue
        let header = "Navn\(d)Pris per måned (NOK)\(d)Neste trekkdato\(d)Status\(d)Notat"
        let lines = subscriptions.map { subscription in
            let name = csvEscaped(subscription.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Abonnement", delimiter: delimiter)
            let price = Formatters.nokString(subscription.priceNOK)
            let date = Formatters.dateFull.string(from: subscription.nextChargeDate)
            let status = subscription.isActive ? "Aktiv" : "Avsluttet"
            let note = csvEscaped(subscription.note ?? "", delimiter: delimiter)
            return "\(name)\(d)\(price)\(d)\(date)\(d)\(status)\(d)\(note)"
        }
        return ([header] + lines).joined(separator: "\n")
    }

    static func writeCSV(content: String, includeBOM: Bool) throws -> URL {
        let fileName = "abonnementer-\(timestamp()).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let final = includeBOM ? "\u{FEFF}\(content)" : content
        try final.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nb_NO")
        formatter.dateFormat = "yyyyMMdd-HHmm"
        return formatter.string(from: Date())
    }

    private static func csvEscaped(_ value: String, delimiter: CSVDelimiter) -> String {
        let needsQuotes = value.contains("\"") || value.contains(delimiter.rawValue) || value.contains("\n")
        var escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        if needsQuotes {
            escaped = "\"\(escaped)\""
        }
        return escaped
    }
}

enum CSVDelimiter: String, CaseIterable {
    case semicolon = ";"
    case comma = ","

    var label: String {
        switch self {
        case .semicolon:
            return "Semikolon"
        case .comma:
            return "Komma"
        }
    }
}
