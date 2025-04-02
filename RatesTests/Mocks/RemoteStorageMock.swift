import Foundation
@testable import Rates

final class RemoteStorageMock: RemoteStorageProtocol {
    enum Invocation: Equatable {
        case getRates(baseCurrency: String)
        case getCurrencies
    }

    private(set) var invocations: [Invocation] = []

    var getRatesResult: Result<[String : Double], AppError> = .success([:])
    func getRates(baseCurrency: String) async throws(Rates.AppError) -> [String : Double] {
        invocations.append(.getRates(baseCurrency: baseCurrency))
        return try getRatesResult.get()
    }

    var getCurrenciesResult: Result<[String : String], AppError> = .success([:])
    func getCurrencies() async throws(Rates.AppError) -> [String : String] {
        invocations.append(.getCurrencies)
        return try getCurrenciesResult.get()
    }
}
