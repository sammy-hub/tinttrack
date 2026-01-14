import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: AppTab = .clients
    @State private var showingOnboarding = false
    @State private var didSetInitialOnboarding = false
    @Query(sort: \AppSettings.id) private var settingsList: [AppSettings]

    var body: some View {
        let hasCompletedOnboarding = settingsList.first?.hasCompletedOnboarding ?? false

        TabView(selection: $selectedTab) {
            Tab("Clients", systemImage: "person.2", value: .clients) {
                ClientsRootView()
            }
            Tab("Inventory", systemImage: "shippingbox", value: .inventory) {
                InventoryRootView()
            }
            Tab("Shopping List", systemImage: "checklist", value: .shoppingList) {
                ShoppingListRootView()
            }
            Tab("Settings", systemImage: "gear", value: .settings) {
                SettingsRootView()
            }
        }
        .task(id: settingsList.first?.id) {
            if didSetInitialOnboarding == false {
                showingOnboarding = hasCompletedOnboarding == false
                didSetInitialOnboarding = true
            }
        }
        .onChange(of: hasCompletedOnboarding) { _, newValue in
            if newValue {
                showingOnboarding = false
            } else if didSetInitialOnboarding {
                showingOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            if let settings = settingsList.first {
                OnboardingFlowView(isPresented: $showingOnboarding, settings: settings)
            } else {
                ContentUnavailableView {
                    Label("Settings Missing", systemImage: "exclamationmark.triangle")
                } description: {
                    Text("Unable to load onboarding.")
                }
            }
        }
    }
}
