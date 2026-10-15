import Foundation
import StoreKit

/// StoreKit 2 is the only path that can grant paid products.
@MainActor @objc final class StarStore: NSObject {
    @objc static let shared = StarStore()
    static let catalog: [Int: String] = [
        3: "com.cschubiner.starstream.doublestars",
        11: "com.cschubiner.starstream.pinkstars",
        12: "com.cschubiner.starstream.stars30000",
        13: "com.cschubiner.starstream.stars70000",
        14: "com.cschubiner.starstream.stars120000",
        15: "com.cschubiner.starstream.stars300000",
        16: "com.cschubiner.starstream.stars1000000"
    ]
    private var products: [String: Product] = [:]
    private var listener: Task<Void, Never>?
    @objc private(set) var busy = false
    @objc static func isPaidItem(_ index: Int) -> Bool { catalog[index] != nil }
    @objc func priceForItem(_ index: Int) -> String? {
        guard let id = Self.catalog[index] else { return nil }
        return products[id]?.displayPrice
    }
    @objc func start() {
        guard listener == nil else { return }
        listener = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }
                do { try await self.deliver(update) }
                catch { self.changed() } // Unverified/undelivered transactions are never granted or finished.
            }
        }
        Task {
            // Recover a purchase interrupted before its durable delivery and finish.
            for await transaction in Transaction.unfinished { try? await deliver(transaction) }
            try? await refreshEntitlements()
        }
    }
    func loadProducts() async {
        do {
            let loaded = try await Product.products(for: Array(Self.catalog.values))
            products = Dictionary(uniqueKeysWithValues: loaded.map { ($0.id, $0) })
        } catch { products = [:] }
        changed()
    }
    @objc func reloadProducts() { Task { await loadProducts() } }
    @objc func refreshOwnedProducts() { Task { try? await refreshEntitlements() } }
    @objc func purchaseItem(_ index: Int, completion: @escaping (String?) -> Void) {
        guard !busy, let id = Self.catalog[index], let product = products[id] else {
            completion("The App Store is unavailable. Please try again when you are online."); return
        }
        busy = true
        Task {
            defer { busy = false; changed() }
            do {
                switch try await product.purchase() {
                case .success(let result): try await deliver(result); completion(nil)
                case .userCancelled: completion(nil)
                case .pending: completion("This purchase is pending approval. Your items will arrive after Apple confirms it.")
                @unknown default: completion("The purchase could not be completed. Please try again.")
                }
            } catch { completion(error.localizedDescription) }
        }
    }
    @objc func restorePurchases(_ completion: @escaping (String?) -> Void) {
        guard !busy else { return }
        busy = true
        Task {
            defer { busy = false; changed() }
            do {
                try await AppStore.sync()
                try await refreshEntitlements()
                completion("Purchased perks have been restored. Consumable star packs cannot be restored after they are delivered.")
            } catch { completion(error.localizedDescription) }
        }
    }
    func deliver(_ result: VerificationResult<Transaction>) async throws {
        guard case .verified(let transaction) = result else { throw StoreError.unverified }
        guard Self.catalog.values.contains(transaction.productID) else { return }
        if transaction.revocationDate != nil {
            DataStorage.revokeProduct(transaction.productID)
        } else {
            guard DataStorage.grantProduct(transaction.productID, transactionID: String(transaction.id)) else {
                throw StoreError.persistence
            }
        }
        await transaction.finish()
        changed()
    }
    func refreshEntitlements() async throws {
        var owned: [String] = []
        // Inspect each permanent product's latest signed transaction, including refunds.
        for index in [3, 11] {
            let id = Self.catalog[index]!
            guard let result = await Transaction.latest(for: id) else { continue }
            guard case .verified(let transaction) = result else { throw StoreError.unverified }
            if transaction.revocationDate == nil, transaction.productType == .nonConsumable {
                owned.append(id)
                try await deliver(result)
            }
        }
        DataStorage.reconcileOwnedProducts(owned)
        changed()
    }
    private func changed() {
        NotificationCenter.default.post(name: Notification.Name("StarStoreUpdated"), object: self)
    }
    enum StoreError: LocalizedError {
        case unverified, persistence
        var errorDescription: String? {
            switch self {
            case .unverified: return "Apple could not verify this purchase. No items were granted."
            case .persistence: return "Your purchase could not be saved. Please reopen the app to retry delivery."
            }
        }
    }
}
