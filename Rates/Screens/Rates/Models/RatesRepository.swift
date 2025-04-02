import SwiftUI
import SwiftData
import Combine

protocol RatesRepositoryProtocol: ObservableObject, CurrenciesRepositoryDelegate {
    @MainActor
    var state: ContentState<[RateItem]> { get set }

    func add(_ newItem: RateItem)
    func remove(_ item: RateItem)

    func refresh() async

    func dispose()
}

final class RatesRepository: RatesRepositoryProtocol {
    @Published var state: ContentState<[RateItem]> = .empty

    private var items: [RateItem] = [] {
        didSet {
            Task {
                await MainActor.run {
                    state = items.isEmpty ? .empty : .loaded(items)
                }
            }
        }
    }
    private var cachedModels: [RateDataModel] = []
    private let localStorage: LocalStorageProtocol
    private let remoteStorage: RemoteStorageProtocol

    private var timer: Timer?

    init(
        localStorage: LocalStorageProtocol,
        remoteStorage: RemoteStorageProtocol
    ) {    
        self.localStorage = localStorage
        self.remoteStorage = remoteStorage
    }

    func startTimer() async {
        await MainActor.run {
            timer?.invalidate()
            let callback = self.timerFired
            timer = Timer.scheduledTimer (withTimeInterval: 3.0, repeats: false) {_ in
                callback()
            }
        }
    }

    func timerFired() {
        Task {
            await refresh()
        }
    }

    func add(_ newItem: RateItem) {
        do {
            try localStorage.add(RateDataModel(with: newItem))
            items.append(newItem)
        } catch {
            // ?
        }
    }

    func remove(_ item: RateItem) {
        let models = cachedModels.filter { $0.sign == item.sign }
        models.forEach { model in
            try? localStorage.delete(model)
        }
        items.removeAll { $0.sign == item.sign }
    }

    func refresh() async {
        await MainActor.run {
            state = state.toLoading()
        }
        do {            
            let result = try await remoteStorage.getRates()
            await updateRates(result)
            await startTimer()
        } catch {
            await MainActor.run {
                state = .error(error)
            }
        }
    }

    func updateRates(_ rates: [String : Double]) async {
        do {
            let result: [RateDataModel] = try await localStorage.fetch().sorted { $0.sign < $1.sign }
            for model in result {
                if let rate = rates[model.sign.lowercased()] ?? rates[model.sign.uppercased()] {
                    model.rate = rate
                    try await localStorage.update(model)
                }
            }
            cachedModels = result
            await MainActor.run {
                items = result.map(RateItem.init(with: ))
            }
        } catch {
            await MainActor.run {
                state = .error(error)
            }
        }
    }

    func dispose() {
        timer?.invalidate()
    }
}

private extension RateItem {
    init(with model: RateDataModel) {
        self.init(
            updated: model.timestamp,
            sign: model.sign,
            title: model.sign,
            subtitle: model.sign,
            rate: model.rate,
            delta: 0
        )
    }

    init(with item: CurrencyItem) {
        self.init(
            updated: Date(),
            sign: item.sign,
            title: item.title,
            subtitle: item.subtitle,
            rate: 0,
            delta: 0
        )
    }
}

private extension RateDataModel {
    convenience init(with item: RateItem) {
        self.init(
            sign: item.sign,
            title: item.title,
            rate: item.rate,
            timestamp: item.updated
        )
    }
}

extension RatesRepositoryProtocol where Self: CurrenciesRepositoryDelegate {
    func selectedCurrencies() async -> [String] {
        switch await state {
        case .loaded(let data), .refreshing(let data):
            return data.map { $0.sign }
        default:
            return []
        }
    }
    
    func onComplete(_ addedCurrencies: [CurrencyItem]) {
        for item in addedCurrencies {
            add(RateItem(with: item))
        }
        Task {
            await refresh()
        }
    }
}

final class PreviewRatesRepository: RatesRepositoryProtocol {
    @Published var state: ContentState<[RateItem]> = .empty

    private var items: [RateItem] = [] {
        didSet {
            Task {
                await MainActor.run {
                    state = items.isEmpty ? .empty : .loaded(items)
                }
            }
        }
    }

    func add(_ newItem: RateItem) {
        items.append(newItem)
    }

    func remove(_ item: RateItem) {
        items.removeAll { $0.sign == item.sign }
    }

    func refresh() async {}

    func dispose() {}
}
