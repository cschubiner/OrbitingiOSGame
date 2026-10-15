import XCTest
import StoreKit
import StoreKitTest
@testable import StarStream

@MainActor final class StorePurchaseTests: XCTestCase {
    private var session: SKTestSession!
    private var backup: [String: Any]?
    private var domain: String { Bundle.main.bundleIdentifier! }
    private var wallet: UserWallet { UserWallet.sharedInstance() as! UserWallet }
    private var upgrades: UpgradeManager { UpgradeManager.sharedInstance() as! UpgradeManager }
    override func setUp() async throws {
        executionTimeAllowance = 30
        backup = UserDefaults.standard.persistentDomain(forName: domain)
        UserDefaults.standard.removePersistentDomain(forName: domain)
        DataStorage.fetchData()
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "StarStream", withExtension: "storekit"))
        session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        // This product exists only in the local configuration. Never fall through to a real store purchase.
        let guardProducts = try await Product.products(for: ["com.cschubiner.starstream.testguard"])
        guard !guardProducts.isEmpty else {
            let visible = try await Product.products(for: Array(StarStore.catalog.values))
            XCTFail("Local guard missing; visible products: \(visible.map { $0.id })")
            throw NSError(domain: "LocalStoreKitTestingUnavailable", code: 1)
        }
        await StarStore.shared.loadProducts()
    }
    override func tearDown() async throws {
        session.clearTransactions()
        if let backup { UserDefaults.standard.setPersistentDomain(backup, forName: domain) }
        else { UserDefaults.standard.removePersistentDomain(forName: domain) }
        DataStorage.fetchData()
    }
    private func buy(_ index: Int) async -> String? {
        await withCheckedContinuation { continuation in
            StarStore.shared.purchaseItem(index) { continuation.resume(returning: $0) }
        }
    }
    func testConsumablePurchaseIsDeliveredOnceAndSurvivesReload() async throws {
        XCTAssertNotNil(StarStore.shared.priceForItem(12))
        let message = await buy(12)
        XCTAssertNil(message)
        XCTAssertEqual(wallet.getBalance(),30000)
        let snapshot = try XCTUnwrap(UserDefaults.standard.dictionary(forKey: "StarStreamProgressV3"))
        let ids = try XCTUnwrap(snapshot["transactions"] as? [String])
        XCTAssertEqual(ids.count,1)
        XCTAssertTrue(DataStorage.grantProduct(StarStore.catalog[12]!,transactionID:ids[0]))
        XCTAssertEqual(wallet.getBalance(),30000)
        DataStorage.fetchData()
        XCTAssertEqual(wallet.getBalance(),30000)
        let second = await buy(12)
        XCTAssertNil(second)
        XCTAssertEqual(wallet.getBalance(),60000)
    }
    func testPermanentPerkPurchaseAndRestore() async throws {
        for index in [3, 11] {
            let message = await buy(index)
            XCTAssertNil(message)
            XCTAssertTrue((upgrades.upgradeItems[index] as! UpgradeItem).purchased)
            upgrades.setUpgradeIndex(Int32(index),purchased:false,equipped:false)
        }
        DataStorage.storeData()
        let restored: String? = await withCheckedContinuation { continuation in
            StarStore.shared.restorePurchases { continuation.resume(returning:$0) }
        }
        XCTAssertTrue(restored?.contains("restored") == true)
        for index in [3, 11] {
            XCTAssertTrue((upgrades.upgradeItems[index] as! UpgradeItem).purchased)
        }
        XCTAssertEqual(wallet.getBalance(),0)
    }
    func testEveryStarPackMatchesAdvertisedAmount() async throws {
        var expected: Int32 = 0
        for (index, amount) in [(12, 30000), (13, 70000), (14, 120000), (15, 300000), (16, 1000000)] {
            let message = await buy(index)
            XCTAssertNil(message)
            expected += Int32(amount)
            XCTAssertEqual(wallet.getBalance(), expected)
        }
        DataStorage.fetchData()
        XCTAssertEqual(wallet.getBalance(), 1520000)
    }
    func testCancelledPurchaseDoesNotGrantStars() async throws {
        if #available(iOS 17.0, *) {
            try await session.setSimulatedError(.generic(.userCancelled),forAPI:.purchase)
            _ = await buy(12)
            XCTAssertEqual(wallet.getBalance(),0)
        }
    }
    func testPendingPurchaseDoesNotGrantBeforeApproval() async throws {
        session.askToBuyEnabled = true
        let message = await buy(12)
        XCTAssertTrue(message?.contains("pending") == true)
        XCTAssertEqual(wallet.getBalance(),0)
        let transaction = try XCTUnwrap(session.allTransactions().last)
        try session.approveAskToBuyTransaction(identifier: transaction.identifier)
        for _ in 0..<100 where wallet.getBalance() == 0 {
            try await Task.sleep(nanoseconds:50_000_000)
        }
        XCTAssertEqual(wallet.getBalance(),30000)
    }
    func testRefundRevokesPermanentPerk() async throws {
        _ = await buy(11)
        XCTAssertTrue((upgrades.upgradeItems[11] as! UpgradeItem).purchased)
        let transaction = try XCTUnwrap(session.allTransactions().last)
        try session.refundTransaction(identifier: transaction.identifier)
        // Apple's refund update arrives asynchronously through Transaction.updates.
        for _ in 0..<100 where (upgrades.upgradeItems[11] as! UpgradeItem).purchased {
            try await Task.sleep(nanoseconds:50_000_000)
        }
        try await StarStore.shared.refreshEntitlements()
        DataStorage.fetchData()
        XCTAssertFalse((upgrades.upgradeItems[11] as! UpgradeItem).purchased)
        XCTAssertFalse((upgrades.upgradeItems[11] as! UpgradeItem).equipped)
    }
    func testWalletAdditionClampsWithoutOverflow() {
        wallet.balance = Int32.max - 10
        wallet.addCoins(1000000)
        XCTAssertEqual(wallet.getBalance(),Int32.max)
    }
}
