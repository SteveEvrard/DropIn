import Foundation
import StoreKit

enum SubscriptionEntitlementChecker {
    /// Returns `true` when the current App Store account has an active entitlement
    /// for any of our subscription products (including free trial).
    static func isEntitledNow() async -> Bool {
        let now = Date()
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard SubscriptionProductIDs.all.contains(transaction.productID) else { continue }
            
            // If Apple revoked/refunded, treat as not entitled.
            if transaction.revocationDate != nil { continue }
            
            // For auto-renewable subscriptions, expirationDate indicates active entitlement.
            if let expiration = transaction.expirationDate {
                if expiration > now { return true }
                continue
            }
            
            // If no expiration date, treat as entitled (covers some non-consumables; safe fallback).
            return true
        }
        
        return false
    }
}

