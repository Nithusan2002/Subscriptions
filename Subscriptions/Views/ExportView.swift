//
//  ExportView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI
import UIKit

struct ExportView: View {
    @EnvironmentObject var store: SubscriptionStore
    @State private var exportURL: URL? = nil
    @State private var isPresentingShare = false
    @State private var errorMessage: String? = nil
    @State private var isPresentingPreview = false
    @State private var includeEnded = true
    @State private var delimiter: CSVDelimiter = .semicolon
    @State private var includeBOM = true
    @State private var lastExportedText = ""
    @State private var showCopiedPath = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(DesignTokens.accent)

            Text("Eksporter")
                .font(DesignTokens.sectionTitleFont)

            Text("Last ned abonnementene dine som CSV.")
                .font(DesignTokens.bodyFont)
                .foregroundStyle(DesignTokens.subtleText)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                Toggle("Inkluder avsluttede", isOn: $includeEnded)

                Picker("Separator", selection: $delimiter) {
                    ForEach(CSVDelimiter.allCases, id: \.self) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Excel-modus (UTF-8 BOM)", isOn: $includeBOM)
            }

            Button("Eksporter CSV") {
                exportCSV()
            }
            .buttonStyle(.borderedProminent)
            .disabled(subscriptionsToExport.isEmpty)

            Button("Forhåndsvis CSV") {
                isPresentingPreview = true
            }
            .buttonStyle(.bordered)
            .disabled(subscriptionsToExport.isEmpty)

            if subscriptionsToExport.isEmpty {
                Text("Ingen abonnementer å eksportere.")
                    .font(DesignTokens.captionFont)
                    .foregroundStyle(DesignTokens.subtleText)
            }

            if let exportURL {
                Button("Åpne i Filer") {
                    isPresentingShare = true
                }
                .buttonStyle(.bordered)

                Button("Kopier filsti") {
                    UIPasteboard.general.string = exportURL.path
                    showCopiedPath = true
                }
                .buttonStyle(.bordered)
            }

            if !lastExportedText.isEmpty {
                Text("Sist eksportert: \(lastExportedText)")
                    .font(DesignTokens.captionFont)
                    .foregroundStyle(DesignTokens.subtleText)
            }
        }
        .padding(24)
        .navigationTitle("Eksporter")
        .sheet(isPresented: $isPresentingShare) {
            if let exportURL {
                ShareSheet(items: [exportURL])
            }
        }
        .sheet(isPresented: $isPresentingPreview) {
            CSVPreviewView(csvText: CSVExporter.subscriptionsCSV(subscriptions: subscriptionsToExport, delimiter: delimiter))
        }
        .alert("Kopiert", isPresented: $showCopiedPath) {
            Button("OK") {}
        } message: {
            Text("Filstien er kopiert til utklippstavlen.")
        }
        .alert("Kunne ikke eksportere", isPresented: Binding(
            get: { errorMessage != nil },
            set: { newValue in
                if !newValue { errorMessage = nil }
            }
        )) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "")
        }
        .onAppear {
            updateLastExportedText()
        }
    }

    private func exportCSV() {
        do {
            let csv = CSVExporter.subscriptionsCSV(subscriptions: subscriptionsToExport, delimiter: delimiter)
            let url = try CSVExporter.writeCSV(content: csv, includeBOM: includeBOM)
            exportURL = url
            isPresentingShare = true
            UserDefaults.standard.set(Date(), forKey: AppDefaults.lastExportedAt)
            updateLastExportedText()
        } catch {
            errorMessage = "Prøv igjen om et øyeblikk."
        }
    }

    private var subscriptionsToExport: [Subscription] {
        includeEnded ? store.subscriptions : store.subscriptions.filter { $0.isActive }
    }

    private func updateLastExportedText() {
        guard let date = UserDefaults.standard.object(forKey: AppDefaults.lastExportedAt) as? Date else {
            lastExportedText = ""
            return
        }
        lastExportedText = Formatters.dateFull.string(from: date)
    }
}

#Preview {
    NavigationStack {
        ExportView()
            .environmentObject(SubscriptionStore())
    }
}
