//
//  StoreKitManager.swift
//  Subscriptions
//
//  Created by Nithusan Krishnasamymudali on 06/01/2026.
//

import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    static let monthlyProductID = "com.example.subscriptions.pro.monthly"
    static let yearlyProductID = "com.example.subscriptions.pro.yearly"

    @Published private(set) var products: [Product] = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: String? = nil

    private var updatesTask: Task<Void, Never>? = nil

    init() {
        updatesTask = listenForTransactions()
        Task {
            await refreshEntitlements()
            await loadProducts()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    var monthlyProduct: Product? {
        products.first(where: { $0.id == Self.monthlyProductID })
    }

    var yearlyProduct: Product? {
        products.first(where: { $0.id == Self.yearlyProductID })
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: [Self.monthlyProductID, Self.yearlyProductID])
        } catch {
            lastError = error.localizedDescription
        }
    }

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if let transaction = try? verify(verification) {
                    await transaction.finish()
                    updateProStatus(true)
                    return true
                }
                return false
            case .userCancelled, .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    func refreshEntitlements() async {
        var isPro = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? verify(result) {
                if transaction.productID == Self.monthlyProductID || transaction.productID == Self.yearlyProductID {
                    isPro = true
                }
            }
        }
        updateProStatus(isPro)
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { continue }
                if let transaction = try? self.verify(result) {
                    if transaction.productID == Self.monthlyProductID || transaction.productID == Self.yearlyProductID {
                        await MainActor.run {
                            self.updateProStatus(true)
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }

    private func updateProStatus(_ isPro: Bool) {
        UserDefaults.standard.set(isPro, forKey: AppDefaults.isPro)
    }

    private func verify<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreKitError.failedVerification
        }
    }
}
