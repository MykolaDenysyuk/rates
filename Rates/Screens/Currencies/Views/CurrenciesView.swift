import SwiftUI

struct CurrenciesView<Repository: CurrenciesRepositoryProtocol>: View {
    @StateObject var repository: Repository
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""


    var body: some View {
        NavigationStack {
            ContentView(state: repository.state) { items in
                List(items) { item in
                    CurrencyTileView(item: item)
                    .onTapGesture {
                        repository.toggle(item)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .animation(.easeInOut(duration: 0.1), value: repository.state.isLoading)
            .task {
                await repository.load()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Add new").font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: done) {
                        Text("Done")
                    }
                }
            }
            .searchable(text: $repository.searchText)
            .task {
                await repository.load()
            }
        }
    }

    private func done() {
        repository.complete()
        dismiss()
    }
}

#Preview {
    CurrenciesView(repository: PreviewCurrenciesRepository())
}
