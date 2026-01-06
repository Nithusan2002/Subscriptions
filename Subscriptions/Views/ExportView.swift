//
//  ExportView.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import SwiftUI

struct ExportView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(.tint)

            Text("Eksporter")
                .font(DesignTokens.sectionTitleFont)

            Text("Kommer snart. Eksport er planlagt, men ikke i MVP.")
                .font(DesignTokens.bodyFont)
                .foregroundStyle(DesignTokens.subtleText)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .navigationTitle("Eksporter")
    }
}

#Preview {
    NavigationStack {
        ExportView()
    }
}
