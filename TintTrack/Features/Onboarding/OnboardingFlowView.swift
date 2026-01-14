import SwiftUI

struct OnboardingFlowView: View {
    @Binding var isPresented: Bool
    let settings: AppSettings

    @State private var stepIndex = 0
    @State private var showingPaywall = false

    var body: some View {
        if showingPaywall {
            PaywallView {
                completeOnboarding()
            }
        } else {
            OnboardingPagerView(
                stepIndex: $stepIndex,
                settings: settings,
                finish: {
                    showingPaywall = true
                }
            )
        }
    }

    private func completeOnboarding() {
        settings.hasCompletedOnboarding = true
        isPresented = false
    }
}

struct OnboardingPagerView: View {
    @Binding var stepIndex: Int
    let settings: AppSettings
    let finish: () -> Void

    var body: some View {
        let steps = OnboardingStep.allCases

        return VStack(spacing: 24) {
            TabView(selection: $stepIndex) {
                ForEach(steps.indices, id: \.self) { index in
                    let step = steps[index]
                    OnboardingStepView(
                        title: step.title,
                        message: step.message,
                        systemImage: step.systemImage,
                        accessory: {
                            if step == .sync {
                                OnboardingSyncToggle(settings: settings)
                            }
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            HStack {
                Button(stepIndex == 0 ? "Skip" : "Back") {
                    if stepIndex == 0 {
                        finish()
                    } else {
                        stepIndex -= 1
                    }
                }

                Spacer()

                Button(stepIndex == steps.count - 1 ? "Continue" : "Next") {
                    if stepIndex == steps.count - 1 {
                        finish()
                    } else {
                        stepIndex += 1
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 24)
    }
}

struct OnboardingStepView<Accessory: View>: View {
    let title: String
    let message: String
    let systemImage: String
    @ViewBuilder let accessory: () -> Accessory

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text(title)
                .font(.title2.weight(.semibold))
                .multilineTextAlignment(.center)

            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            accessory()
        }
        .padding(.horizontal, 28)
    }
}

struct OnboardingSyncToggle: View {
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
            Toggle("Enable iCloud Sync", isOn: binding)
            Text("You can change this later in Settings.")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}

enum OnboardingStep: CaseIterable, Equatable {
    case welcome
    case workflow
    case sync

    var title: String {
        switch self {
        case .welcome:
            return "Welcome to TintTrack"
        case .workflow:
            return "Formulas Update Stock"
        case .sync:
            return "Optional iCloud Sync"
        }
    }

    var message: String {
        switch self {
        case .welcome:
            return "Fast, list-first tracking for inventory and client formulas."
        case .workflow:
            return "Record visits and formulas to automatically deduct inventory and keep your shopping list ready."
        case .sync:
            return "Enable iCloud to keep your data in sync across devices."
        }
    }

    var systemImage: String {
        switch self {
        case .welcome:
            return "checklist"
        case .workflow:
            return "wand.and.stars"
        case .sync:
            return "icloud"
        }
    }
}
