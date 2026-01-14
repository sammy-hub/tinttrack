import SwiftUI
import SwiftData

struct ClientDetailView: View {
    @Query private var clients: [Client]
    @Query private var visits: [Visit]

    let clientID: UUID

    @State private var showingNewVisit = false
    @State private var showingPaywall = false

    init(clientID: UUID) {
        self.clientID = clientID
        _clients = Query(filter: #Predicate { $0.id == clientID })
        _visits = Query(
            filter: #Predicate { $0.client?.id == clientID },
            sort: \Visit.date,
            order: .reverse
        )
    }

    var body: some View {
        if let client = clients.first {
            ClientDetailContent(
                client: client,
                visits: visits,
                showingNewVisit: $showingNewVisit,
                showingPaywall: $showingPaywall
            )
            .sheet(isPresented: $showingNewVisit) {
                NewVisitView(client: client)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView {
                    showingPaywall = false
                }
            }
        } else {
            ContentUnavailableView {
                Label("Client Missing", systemImage: "exclamationmark.triangle")
            } description: {
                Text("This client is no longer available.")
            }
        }
    }
}

struct ClientDetailContent: View {
    let client: Client
    let visits: [Visit]
    @Binding var showingNewVisit: Bool
    @Binding var showingPaywall: Bool
    @Environment(SubscriptionService.self) private var subscriptionService
    @Query(sort: \AppSettings.id) private var settingsList: [AppSettings]

    var body: some View {
        let debugBypass = settingsList.first?.debugBypassSubscription ?? false
        let canCreate = subscriptionService.isSubscribed || debugBypass

        List {
            Section("Client") {
                Text(client.name)
            }

            Section {
                Button("New Visit") {
                    if canCreate {
                        showingNewVisit = true
                    } else {
                        showingPaywall = true
                    }
                }
            }

            Section("Visits") {
                if visits.isEmpty {
                    Text("No visits yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(visits) { visit in
                        VisitRow(visit: visit)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(client.name)
    }
}

struct VisitRow: View {
    let visit: Visit

    var body: some View {
        HStack {
            Text(visit.date, format: .dateTime.year().month().day())
            Spacer()
            Text("\(visit.formulas?.count ?? 0)")
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(visit.formulas?.count ?? 0) formulas")
    }
}
