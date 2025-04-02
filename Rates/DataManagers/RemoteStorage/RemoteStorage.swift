import Foundation

/// Remote storage handler interface
protocol RemoteStorageProtocol {
    func getCurrencies() async throws(AppError) -> [String: String]
    func getRates(baseCurrency: String) async throws(AppError) -> [String: Double]
}

extension RemoteStorageProtocol {
    func getRates() async throws(AppError) -> [String: Double] {
        return try await getRates(baseCurrency: "USD")
    }
}


final class RemoteStorage: RemoteStorageProtocol {
    static private let basePath = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api"
    private let session = URLSession.shared

    func getCurrencies() async throws(AppError) -> [String: String] {
        guard let url = URL(string: "\(Self.basePath)@latest/v1/currencies.json") else {
            throw AppError.invalidInput
        }

        do {
            let result = try await session.data(from: url)

            if let httpResponse = result.1 as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let data = result.0
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    return json as? [String: String] ?? [:]
                } catch {
                    throw AppError.unknownError(reason: error)
                }
            } else {
                throw AppError.networkFailure
            }
        } catch {
            throw AppError.unknownError(reason: error)
        }

    }

    func getRates(baseCurrency: String) async throws(AppError) -> [String: Double] {
        guard let url = URL(string: "\(Self.basePath)@latest/v1/currencies/\(baseCurrency.lowercased()).json") else {
            throw AppError.invalidInput
        }

        do {
            let result = try await session.data(from: url)

            if let httpResponse = result.1 as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let data = result.0
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
                    let rawRates = json[baseCurrency.lowercased()]
                    return rawRates as? [String: Double] ?? [:]
                } catch {
                    throw AppError.unknownError(reason: error)
                }
            } else {
                throw AppError.networkFailure
            }
        } catch {
            throw AppError.unknownError(reason: error)
        }
    }
}
