import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var products: [Product] = []
    @Published private(set) var hasActiveEntitlement: Bool = false
    @Published private(set) var lastErrorMessage: String?
    
    private var updatesTask: Task<Void, Never>?
    
    init() {
        updatesTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await refreshEntitlements()
            isLoading = false
        }
    }
    
    deinit {
        updatesTask?.cancel()
    }
    
    var primaryProduct: Product? {
        products.first(where: { $0.id == SubscriptionProductIDs.dropInPremium }) ?? products.first
    }
    
    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: Array(SubscriptionProductIDs.all))
            products = storeProducts.sorted(by: { $0.displayName < $1.displayName })
        } catch {
            lastErrorMessage = "Unable to load subscription options. \(error.localizedDescription)"
            products = []
        }
    }
    
    func refreshEntitlements() async {
        hasActiveEntitlement = await SubscriptionEntitlementChecker.isEntitledNow()
    }
    
    func purchase(_ product: Product) async {
        lastErrorMessage = nil
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                await transaction.finish()
                await refreshEntitlements()
                
            case .userCancelled:
                break
                
            case .pending:
                lastErrorMessage = "Purchase is pending approval."
                
            @unknown default:
                lastErrorMessage = "Purchase failed due to an unknown error."
            }
        } catch {
            lastErrorMessage = "Purchase failed. \(error.localizedDescription)"
        }
    }
    
    func restorePurchases() async {
        lastErrorMessage = nil
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            lastErrorMessage = "Restore failed. \(error.localizedDescription)"
        }
    }
    
    // MARK: - Private
    
    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                do {
                    let transaction = try await self.checkVerified(result)
                    await transaction.finish()
                    await self.refreshEntitlements()
                } catch {
                    // Ignore unverified transactions.
                }
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let signedType):
            return signedType
        }
    }
}

