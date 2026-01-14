import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.openURL) private var openURL

    let onContinue: () -> Void

    @State private var isProcessing = false
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TintTrack Pro")
                            .font(.title2.weight(.semibold))
                        Text("Create new visits and inventory items, keep your shopping list updated, and sync across devices.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                Section("Plan") {
                    HStack {
                        Text("Monthly")
                        Spacer()
                        Text(subscriptionService.product?.displayPrice ?? "$9.99")
                    }
                    Text("Auto-renews monthly until canceled.")
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        Task {
                            await purchase()
                        }
                    } label: {
                        Label("Subscribe", systemImage: "checkmark.seal")
                    }
                    .disabled(isProcessing || subscriptionService.product == nil)

                    Button("Restore Purchases") {
                        Task {
                            await restore()
                        }
                    }
                    .disabled(isProcessing)

                    Button("Manage Subscription") {
                        openURL(URL(string: "https://apps.apple.com/account/subscriptions")!)
                    }
                }

                Section {
                    Button("Continue in Read-Only") {
                        onContinue()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await subscriptionService.refreshStatus()
            }
            .onChange(of: subscriptionService.lastErrorMessage) { _, newValue in
                showingError = newValue != nil
            }
            .onChange(of: subscriptionService.isSubscribed) { _, newValue in
                if newValue {
                    onContinue()
                }
            }
            .alert("Purchase Error", isPresented: $showingError) {
                Button("OK") {
                    subscriptionService.clearError()
                }
            } message: {
                Text(subscriptionService.lastErrorMessage ?? "Something went wrong.")
            }
        }
    }

    private func purchase() async {
        isProcessing = true
        defer { isProcessing = false }
        _ = await subscriptionService.purchase()
    }

    private func restore() async {
        isProcessing = true
        defer { isProcessing = false }
        await subscriptionService.restore()
    }
}

struct SubscriptionStatusView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.openURL) private var openURL

    @State private var isProcessing = false
    @State private var showingError = false

    var body: some View {
        List {
            Section("Status") {
                HStack {
                    Text("Subscription")
                    Spacer()
                    Text(statusLabel)
                        .foregroundStyle(statusColor)
                }
            }

            Section("Plan") {
                HStack {
                    Text("Monthly")
                    Spacer()
                    Text(subscriptionService.product?.displayPrice ?? "$9.99")
                }
            }

            Section {
                Button {
                    Task {
                        await purchase()
                    }
                } label: {
                    Label("Subscribe", systemImage: "checkmark.seal")
                }
                .disabled(isProcessing || subscriptionService.isSubscribed)

                Button("Restore Purchases") {
                    Task {
                        await restore()
                    }
                }
                .disabled(isProcessing)

                Button("Manage Subscription") {
                    openURL(URL(string: "https://apps.apple.com/account/subscriptions")!)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Subscription")
        .task {
            await subscriptionService.refreshStatus()
        }
        .onChange(of: subscriptionService.lastErrorMessage) { _, newValue in
            showingError = newValue != nil
        }
        .alert("Purchase Error", isPresented: $showingError) {
            Button("OK") {
                subscriptionService.clearError()
            }
        } message: {
            Text(subscriptionService.lastErrorMessage ?? "Something went wrong.")
        }
    }

    private var statusLabel: String {
        switch subscriptionService.state {
        case .active:
            return "Active"
        case .expired:
            return "Expired"
        case .revoked:
            return "Revoked"
        case .inGracePeriod:
            return "Grace Period"
        case .inBillingRetry:
            return "Billing Retry"
        case .notSubscribed:
            return "Not Subscribed"
        case .loading:
            return "Loading"
        case .unknown:
            return "Unknown"
        }
    }

    private var statusColor: Color {
        switch subscriptionService.state {
        case .active:
            return .green
        case .inGracePeriod, .inBillingRetry:
            return .orange
        case .expired, .revoked, .notSubscribed:
            return .secondary
        case .loading, .unknown:
            return .secondary
        }
    }

    private func purchase() async {
        isProcessing = true
        defer { isProcessing = false }
        _ = await subscriptionService.purchase()
    }

    private func restore() async {
        isProcessing = true
        defer { isProcessing = false }
        await subscriptionService.restore()
    }
}
