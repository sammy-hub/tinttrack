import SwiftUI
import SwiftData

struct ClientsRootView: View {
    @Query(sort: \Client.name, order: .forward) private var clients: [Client]

    @State private var showingAddClient = false

    var body: some View {
        NavigationStack {
            List {
                if clients.isEmpty {
                    Section {
                        ClientsEmptyStateView(action: {
                            showingAddClient = true
                        })
                    }
                } else {
                    Section {
                        ForEach(clients) { client in
                            NavigationLink(value: client.id) {
                                ClientRow(client: client)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Clients")
            .navigationDestination(for: UUID.self) { clientID in
                ClientDetailView(clientID: clientID)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddClient = true
                    } label: {
                        Label("Add Client", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientView()
            }
        }
    }
}

struct ClientsEmptyStateView: View {
    let action: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("No Clients", systemImage: "person.crop.circle.badge.plus")
        } description: {
            Text("Add a client to start tracking formulas and visits.")
        } actions: {
            Button("Add Client") {
                action()
            }
        }
    }
}

struct ClientRow: View {
    let client: Client

    var body: some View {
        let visitCount = client.visits?.count ?? 0

        HStack {
            Text(client.name)
            Spacer()
            Text("\(visitCount)")
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(client.name), \(visitCount) visits")
    }
}
