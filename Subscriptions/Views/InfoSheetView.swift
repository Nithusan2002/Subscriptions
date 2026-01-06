//
//  InfoSheetView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct InfoSheetView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let message: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(message)
                    .font(DesignTokens.bodyFont)
                    .foregroundStyle(DesignTokens.subtleText)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    InfoSheetView(title: "Om", message: "En rolig oversikt over abonnementene dine.")
}
