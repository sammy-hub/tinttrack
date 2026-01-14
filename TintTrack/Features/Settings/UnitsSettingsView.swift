import SwiftUI
import SwiftData

struct UnitsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppSettings.id) private var settingsList: [AppSettings]

    var body: some View {
        if let settings = settingsList.first {
            UnitsSettingsContent(settings: settings)
        } else {
            ContentUnavailableView {
                Label("Settings Missing", systemImage: "exclamationmark.triangle")
            } description: {
                Text("Unable to load unit preferences.")
            } actions: {
                Button("Create Settings") {
                    modelContext.insert(AppSettings())
                }
            }
        }
    }
}

struct UnitsSettingsContent: View {
    let settings: AppSettings

    var body: some View {
        @Bindable var settings = settings

        return Form {
            Section("Units") {
                Picker("Preferred Units", selection: $settings.preferredUnits) {
                    ForEach(Units.allCases, id: \.self) { unit in
                        Text(unit == .grams ? "Grams" : "Ounces")
                            .tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                Text("Used for all amounts and unit sizes across the app.")
                    .foregroundStyle(.secondary)
            }

            Section("Step Size") {
                Stepper(value: $settings.stepSizeGrams, in: 1...100, step: 1) {
                    HStack {
                        Text("Grams")
                        Spacer()
                        Text(settings.stepSizeGrams, format: .number.precision(.fractionLength(0)))
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                }
                Stepper(value: $settings.stepSizeOunces, in: 0.01...5, step: 0.01) {
                    HStack {
                        Text("Ounces")
                        Spacer()
                        Text(settings.stepSizeOunces, format: .number.precision(.fractionLength(2)))
                        Text("oz")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Units")
    }
}
