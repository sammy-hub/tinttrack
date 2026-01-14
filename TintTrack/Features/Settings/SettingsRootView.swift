import CloudKit
import SwiftUI
import SwiftData

struct SettingsRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppSettings.id) private var settingsList: [AppSettings]

    var body: some View {
        NavigationStack {
            List {
                Section("Inventory") {
                    NavigationLink("Inventory Categories") {
                        InventoryCategoriesSettingsView()
                    }
                }

                Section("Account") {
                    SignInWithAppleRow()
                    NavigationLink("Subscription") {
                        SubscriptionStatusView()
                    }
                }

                Section("Preferences") {
                    NavigationLink("Units") {
                        UnitsSettingsView()
                    }

                    if let settings = settingsList.first {
                        iCloudRow(settings: settings)
                    } else {
                        Button("Create Settings") {
                            modelContext.insert(AppSettings())
                        }
                    }
                }

#if DEBUG
                Section("Debug") {
                    if let settings = settingsList.first {
                        DebugSubscriptionBypassRow(settings: settings)
                    }
                }
#endif
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
        }
    }
}

struct CloudSyncStatusView: View {
    @State private var statusText = "Checking iCloud status..."

    var body: some View {
        Text(statusText)
            .foregroundStyle(.secondary)
            .task {
                await updateStatus()
            }
    }

    private func updateStatus() async {
        do {
            let status = try await CKContainer.default().accountStatus()
            statusText = message(for: status)
        } catch {
            statusText = "iCloud status unavailable."
        }
    }

    private func message(for status: CKAccountStatus) -> String {
        switch status {
        case .available:
            return "iCloud account available."
        case .noAccount:
            return "No iCloud account is signed in."
        case .restricted:
            return "iCloud access is restricted."
        case .couldNotDetermine:
            return "iCloud status could not be determined."
        case .temporarilyUnavailable:
            return "iCloud is temporarily unavailable."
        @unknown default:
            return "iCloud status unknown."
        }
    }
}

struct iCloudRow: View {
    let settings: AppSettings

    var body: some View {
        let binding = Binding(
            get: { settings.iCloudEnabled },
            set: { newValue in
                settings.iCloudEnabled = newValue
                CloudSyncPreferences.isEnabled = newValue
            }
        )

        return VStack(alignment: .leading, spacing: 8) {
            Toggle("iCloud Sync", isOn: binding)
            Text("Restart the app to apply sync changes.")
                .foregroundStyle(.secondary)
            CloudSyncStatusView()
        }
    }
}

#if DEBUG
struct DebugSubscriptionBypassRow: View {
    let settings: AppSettings

    var body: some View {
        let binding = Binding(
            get: { settings.debugBypassSubscription ?? false },
            set: { settings.debugBypassSubscription = $0 }
        )

        return VStack(alignment: .leading, spacing: 8) {
            Toggle("Bypass Subscription", isOn: binding)
            Text("Debug only. Grants full access without purchase.")
                .foregroundStyle(.secondary)
        }
    }
}
#endif
