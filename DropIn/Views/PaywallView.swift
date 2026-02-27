import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    
    var body: some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            
            VStack(spacing: 12) {
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundColor(Color("ButtonColor"))
                    .padding(.bottom, 4)
                
                Text("DropIn")
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
                        .padding(.bottom, 12)
                } else if let product = subscriptionManager.primaryProduct {
                    Text(primaryOfferText(for: product))
                        .foregroundColor(Color("SecondaryTextColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 4)
                    
                    Text("Cancel anytime in Settings > Subscriptions before the trial ends to avoid charges.")
                        .foregroundColor(Color("SecondaryTextColor"))
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Custom purchase button so the label can be styled/centered like Restore.
                    Button {
                        Task { await subscriptionManager.purchase(product) }
                    } label: {
                        Text(customPurchaseButtonTitle(for: product))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .padding(.horizontal, 16)
                            .background(Color("ButtonColor"))
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    
                    Button {
                        Task { await subscriptionManager.restorePurchases() }
                    } label: {
                        Text("Restore Subscription")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color("PrimaryTextColor"))
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.75))
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 24)
                    
                    HStack(spacing: 18) {
                        if let termsURL = AppPolicyURLs.termsOfUse {
                            Link("Terms of Service", destination: termsURL)
                        } else {
                            Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        }
                        
                        if let privacyURL = AppPolicyURLs.privacyPolicy {
                            Link("Privacy Policy", destination: privacyURL)
                        } else {
                            Link("Privacy Policy", destination: URL(string: "https://steveevrard.github.io/DropIn/")!)
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(Color("ButtonColor"))
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                    
                } else {
                    Text("Subscription options are unavailable right now.")
                        .foregroundColor(Color("SecondaryTextColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                if let error = subscriptionManager.lastErrorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
        }
        .task {
            // Needed for dynamic “trial then price” messaging and the custom purchase button.
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
    
    private func customPurchaseButtonTitle(for product: Product) -> String {
        // Match the kind of label the user is seeing from StoreKit, but with our own styling.
        if let trial = introTrialText(for: product) {
            return "\(trial), then \(pricePerPeriodText(for: product) ?? product.displayPrice)"
        }
        return "Subscribe \(pricePerPeriodText(for: product) ?? product.displayPrice)"
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

