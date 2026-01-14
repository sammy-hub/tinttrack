import Foundation
import StoreKit

@MainActor
@Observable
final class SubscriptionService {
    enum SubscriptionState: Equatable {
        case loading
        case active
        case expired
        case revoked
        case inGracePeriod
        case inBillingRetry
        case notSubscribed
        case unknown
    }

    let productID = "com.yourcompany.shadey.monthly"

    enum SubscriptionServiceError: Error {
        case failedVerification
    }

    private(set) var product: Product?
    private(set) var state: SubscriptionState = .loading
    private(set) var lastErrorMessage: String?

    private var updatesTask: Task<Void, Never>?

    var isSubscribed: Bool {
        switch state {
        case .active, .inGracePeriod, .inBillingRetry:
            return true
        default:
            return false
        }
    }

    init() {
        Task {
            await load()
        }
    }

    func load() async {
        await loadProduct()
        await refreshStatus()
        listenForUpdates()
    }

    func purchase() async -> Bool {
        guard let product else {
            lastErrorMessage = "Subscription unavailable. Try again later."
            return false
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshStatus()
                return isSubscribed
            case .pending, .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            lastErrorMessage = error.localizedDescription
            return false
        }
    }

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshStatus()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    func refreshStatus() async {
        guard let product else {
            state = .notSubscribed
            return
        }

        do {
            let statuses = try await product.subscription?.status ?? []
            guard let status = statuses.first else {
                state = .notSubscribed
                return
            }
            state = mapStatus(status)
        } catch {
            state = .unknown
            lastErrorMessage = error.localizedDescription
        }
    }

    func clearError() {
        lastErrorMessage = nil
    }

    private func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    private func listenForUpdates() {
        updatesTask?.cancel()
        updatesTask = Task {
            for await _ in Transaction.updates {
                await refreshStatus()
            }
        }
    }

    private func mapStatus(_ status: Product.SubscriptionInfo.Status) -> SubscriptionState {
        switch status.state {
        case .subscribed:
            return .active
        case .expired:
            return .expired
        case .revoked:
            return .revoked
        case .inGracePeriod:
            return .inGracePeriod
        case .inBillingRetryPeriod:
            return .inBillingRetry
        default:
            return .unknown
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw SubscriptionServiceError.failedVerification
        }
    }
}
