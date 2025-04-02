import Combine

protocol CurrenciesRepositoryProtocol: ObservableObject {
    @MainActor
    var state: ContentState<[CurrencyItem]> { get set }

    @MainActor
    var searchText: String { get set }

    func load() async
    @MainActor
    func toggle(_ item: CurrencyItem)
    @MainActor
    func complete()
}

protocol CurrenciesRepositoryDelegate: AnyObject {
    func selectedCurrencies() async -> [String]
    func onComplete(_ addedCurrencies: [CurrencyItem])
}

final class CurrenciesRepository: CurrenciesRepositoryProtocol {
    @Published var state: ContentState<[CurrencyItem]> = .empty

    var searchText: String = "" {
        didSet {
            guard searchText != oldValue else { return }
            Task {
                await MainActor.run {
                    reload()
                }
            }
        }
    }

    private let remoteStorage: RemoteStorageProtocol
    private unowned let delegate: CurrenciesRepositoryDelegate
    private var items: [CurrencyItem] = []

    init(
        remoteStorage: RemoteStorageProtocol,
        delegate: CurrenciesRepositoryDelegate
    ) {
        self.remoteStorage = remoteStorage
        self.delegate = delegate
    }

    @MainActor
    private func reload() {
        guard !searchText.isEmpty else {
            return self.state = .loaded(self.items)
        }
        let search = self.searchText.lowercased()
        let filtered = self.items.filter {
            $0.title.lowercased().contains(search)
            || $0.subtitle.lowercased().contains(search)
        }
        self.state = .loaded(filtered)
    }

    func load() async {
        await MainActor.run {
            searchText = ""
            state = state.toLoading()
        }

        do {
            let selectedCurrencies = await delegate.selectedCurrencies()

            let allCurrencies = try await remoteStorage.getCurrencies()
            items = allCurrencies.compactMap {
                guard !selectedCurrencies.contains($0.key) else { return nil }
                return CurrencyItem(
                    sign: $0.key,
                    title: $0.key,
                    subtitle: $0.value,
                    isSelected: false
                )
            }.sorted { $0.title < $1.title }
            await MainActor.run {
                state = items.isEmpty ? .empty : .loaded(items)
            }
        } catch {
            await MainActor.run {
                state = .error(error)
            }
        }
    }

    func toggle(_ item: CurrencyItem) {
        guard let itemIndex = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[itemIndex] = item.toggled()
        reload()
    }

    func complete() {
        let selected = items.filter { $0.isSelected }
        delegate.onComplete(selected)
    }
}


final class PreviewCurrenciesRepository: CurrenciesRepositoryProtocol {
    var state: ContentState<[CurrencyItem]> = .loaded([
        .init(sign: "USD", title: "USD", subtitle: "US Dollars", isSelected: false),
        .init(sign: "CAD", title: "CAD", subtitle: "Canadian Dollars", isSelected: false),
    ])

    var searchText: String = ""

    func load() async {}

    func toggle(_ item: CurrencyItem) {
        state = .loaded([item.toggled()])
    }

    func complete() {}
}
