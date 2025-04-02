import SwiftUI

struct RatesView<Repository: RatesRepositoryProtocol>: View {
    @StateObject var repository: Repository

    var body: some View {
        NavigationStack {
            VStack {
                ContentView(state: repository.state) { items in
                    List(items, id: \.self) { item in
                        NavigationLink {
                            RateItemDetailsView(item: item)
                        } label: {
                            RateItemTileView(item: item)
                                .swipeActions(allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        repository.remove(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash.fill")
                                    }.tint(.red)
                                }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Exchange Rates").font(.headline)
                }
                ToolbarItem {
                    NavigationLink {
                        CurrenciesView(
                            repository: CurrenciesRepository(
                                remoteStorage: RemoteStorage(),
                                delegate: repository
                            )
                        )
                    } label: {
                        Text("Add new")
                    }

                }
            }
        }
        .refreshable {
            // wait for the pull to refresh animation to complete
            try? await Task.sleep(for: .milliseconds(300))
            // wrap in Task to avoid `refresh` being cancelled
            await Task {
                await repository.refresh()
            }.value
        }
        .onAppear {
            Task {
                await repository.refresh()
            }
        }
        .onDisappear {
            repository.dispose()
        }
    }
}

#Preview {
    RatesView(repository: PreviewRatesRepository())
}
