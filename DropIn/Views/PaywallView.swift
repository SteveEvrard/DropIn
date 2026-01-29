import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundColor(Color("ButtonColor"))
                    .padding(.bottom, 8)
                
                Text("DropIn Pro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("PrimaryTextColor"))
                
                Text("A subscription is required to use DropIn.")
                    .foregroundColor(Color("SecondaryTextColor"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                VStack(alignment: .leading, spacing: 10) {
                    PaywallBullet(text: "Save and organize unlimited locations")
                    PaywallBullet(text: "Export KML files")
                    PaywallBullet(text: "Siri + CarPlay support")
                }
                .padding(.top, 8)
                .padding(.horizontal, 24)
                
                Spacer()
                
                if subscriptionManager.isLoading {
                    ProgressView()
                        .padding(.bottom, 8)
                } else {
                    if let product = subscriptionManager.primaryProduct {
                        Text(primaryOfferText(for: product))
                            .foregroundColor(Color("SecondaryTextColor"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Button {
                            Task { await subscriptionManager.purchase(product) }
                        } label: {
                            Text(primaryButtonTitle(for: product))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("ButtonColor"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        
                    } else {
                        Text("Subscription options are unavailable right now.")
                            .foregroundColor(Color("SecondaryTextColor"))
                            .padding(.horizontal, 24)
                    }
                }
                
                if let error = subscriptionManager.lastErrorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                HStack(spacing: 16) {
                    Button {
                        Task { await subscriptionManager.restorePurchases() }
                    } label: {
                        Text("Restore Purchases")
                            .fontWeight(.semibold)
                    }
                    
                    Button {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Manage")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundColor(Color("ButtonColor"))
                .padding(.bottom, 24)
            }
        }
        .task {
            // Ensure we refresh when the paywall appears.
            await subscriptionManager.refreshEntitlements()
            if subscriptionManager.products.isEmpty {
                await subscriptionManager.loadProducts()
            }
        }
    }
    
    private func primaryButtonTitle(for product: Product) -> String {
        if let trial = introTrialText(for: product) {
            return "Start \(trial)"
        }
        return "Subscribe \(pricePerPeriodText(for: product) ?? product.displayPrice)"
    }
    
    private func primaryOfferText(for product: Product) -> String {
        let priceText = pricePerPeriodText(for: product) ?? product.displayPrice
        
        if let trial = introTrialText(for: product) {
            return "\(trial), then \(priceText) until canceled."
        }
        
        return "\(priceText) until canceled."
    }
    
    private func introTrialText(for product: Product) -> String? {
        guard let subscription = product.subscription else { return nil }
        guard let offer = subscription.introductoryOffer else { return nil }
        guard offer.paymentMode == .freeTrial else { return nil }
        
        let period = offer.period
        let duration = periodDescription(period)
        return "\(duration) free trial"
    }
    
    private func pricePerPeriodText(for product: Product) -> String? {
        guard let subscription = product.subscription else { return nil }
        let period = subscription.subscriptionPeriod
        let periodText = periodShortDescription(period)
        return "\(product.displayPrice)/\(periodText)"
    }
    
    private func periodDescription(_ period: Product.SubscriptionPeriod) -> String {
        let value = period.value
        let unit = period.unit
        
        let unitText: String
        switch unit {
        case .day: unitText = value == 1 ? "day" : "days"
        case .week: unitText = value == 1 ? "week" : "weeks"
        case .month: unitText = value == 1 ? "month" : "months"
        case .year: unitText = value == 1 ? "year" : "years"
        @unknown default: unitText = "period"
        }
        
        return "\(value) \(unitText)"
    }
    
    private func periodShortDescription(_ period: Product.SubscriptionPeriod) -> String {
        let value = period.value
        let unit = period.unit
        
        // Prefer human-friendly “month/year” when it’s exactly 1.
        if value == 1 {
            switch unit {
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            @unknown default: return "period"
            }
        }
        
        // Otherwise fall back to pluralized full description (e.g. “3 months”).
        return periodDescription(period)
    }
}

private struct PaywallBullet: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color("Success"))
            Text(text)
                .foregroundColor(Color("PrimaryTextColor"))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
    }
}

