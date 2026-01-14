import SwiftUI
import SwiftData

@main
struct TintTrackApp: App {
    let modelContainer: ModelContainer
    @State private var subscriptionService = SubscriptionService()
    @State private var authService = AuthService()

    init() {
        let cloudSyncEnabled = CloudSyncPreferences.isEnabled
        let schema = Schema([
            Client.self,
            Visit.self,
            Formula.self,
            FormulaLineItem.self,
            InventoryCategory.self,
            InventoryFieldDefinition.self,
            InventoryItem.self,
            InventoryTransaction.self,
            ShoppingListItem.self,
            AppSettings.self
        ])
        let configuration: ModelConfiguration
        if cloudSyncEnabled {
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic
            )
        } else {
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
        }
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        ensureSettings(context: modelContainer.mainContext)

#if DEBUG
        seedDefaultsIfNeeded(context: modelContainer.mainContext)
#endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environment(subscriptionService)
                .environment(authService)
        }
    }

#if DEBUG
    private func seedDefaultsIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<InventoryCategory>()
        let existing = (try? context.fetch(descriptor)) ?? []
        guard existing.isEmpty else {
            return
        }

        let hairColor = InventoryCategory(
            name: "Hair Color",
            fieldDefinitions: [
                InventoryFieldDefinition(name: InventoryFieldKeys.brand, type: .text, order: 0),
                InventoryFieldDefinition(name: InventoryFieldKeys.productLine, type: .text, order: 1),
                InventoryFieldDefinition(name: InventoryFieldKeys.shade, type: .text, order: 2),
                InventoryFieldDefinition(name: InventoryFieldKeys.productSize, type: .number, order: 3),
                InventoryFieldDefinition(name: InventoryFieldKeys.notes, type: .text, order: 4),
                InventoryFieldDefinition(name: InventoryFieldKeys.cost, type: .number, order: 5)
            ],
            isSystem: true
        )

        let developer = InventoryCategory(
            name: "Developer",
            fieldDefinitions: [
                InventoryFieldDefinition(name: InventoryFieldKeys.brand, type: .text, order: 0),
                InventoryFieldDefinition(
                    name: InventoryFieldKeys.volume,
                    type: .picker,
                    pickerOptions: ["10", "20", "30", "40"],
                    order: 1
                ),
                InventoryFieldDefinition(name: InventoryFieldKeys.bottleSize, type: .number, order: 2),
                InventoryFieldDefinition(name: InventoryFieldKeys.notes, type: .text, order: 3),
                InventoryFieldDefinition(name: InventoryFieldKeys.cost, type: .number, order: 4)
            ],
            isSystem: true
        )

        let lightener = InventoryCategory(
            name: "Lightener",
            fieldDefinitions: [
                InventoryFieldDefinition(name: InventoryFieldKeys.brand, type: .text, order: 0),
                InventoryFieldDefinition(name: InventoryFieldKeys.powderType, type: .text, order: 1),
                InventoryFieldDefinition(name: InventoryFieldKeys.bagSize, type: .number, order: 2),
                InventoryFieldDefinition(name: InventoryFieldKeys.notes, type: .text, order: 3),
                InventoryFieldDefinition(name: InventoryFieldKeys.cost, type: .number, order: 4)
            ],
            isSystem: true
        )

        context.insert(hairColor)
        context.insert(developer)
        context.insert(lightener)
    }
#endif

    private func ensureSettings(context: ModelContext) {
        let descriptor = FetchDescriptor<AppSettings>()
        let existing = (try? context.fetch(descriptor)) ?? []
        if let settings = existing.first {
            if CloudSyncPreferences.isEnabled != settings.iCloudEnabled {
                CloudSyncPreferences.isEnabled = settings.iCloudEnabled
            }
            return
        }
        let settings = AppSettings(iCloudEnabled: CloudSyncPreferences.isEnabled)
        context.insert(settings)
    }
}
