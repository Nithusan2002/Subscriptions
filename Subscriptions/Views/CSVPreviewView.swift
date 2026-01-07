//
//  CSVPreviewView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI
import UIKit

struct CSVPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let csvText: String
    @State private var showCopied = false

    var body: some View {
        NavigationStack {
            ScrollView([.horizontal, .vertical]) {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Text(String(format: "%02d", index + 1))
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundStyle(DesignTokens.subtleText)
                                .frame(width: 28, alignment: .trailing)

                            Text(line)
                                .font(.system(size: 12, weight: index == 0 ? .semibold : .regular, design: .monospaced))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .padding(.vertical, 4)
                        .background(index == 0 ? DesignTokens.cardBackground : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .padding()
            }
            .navigationTitle("Forhåndsvis CSV")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Kopier") {
                        UIPasteboard.general.string = csvText
                        showCopied = true
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") { dismiss() }
                }
            }
            .alert("Kopiert", isPresented: $showCopied) {
                Button("OK") {}
            } message: {
                Text("CSV-innholdet er kopiert til utklippstavlen.")
            }
        }
    }

    private var lines: [String] {
        csvText.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
    }
}

#Preview {
    CSVPreviewView(csvText: "Navn;Pris per måned (NOK);Neste trekkdato;Status;Notat\nNetflix;149;24.09;Aktiv;")
}
