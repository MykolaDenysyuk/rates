import XCTest
@testable import Rates

final class CurrenciesRepositoryTests: XCTestCase {
    func testLoad() async throws {
        // Given
        let remoteStorageMock = RemoteStorageMock()
        remoteStorageMock.getCurrenciesResult = .success([
            "ABC": "Amazing Bussiness Currency",
            "XYZ": "Xenomorph Yellow Zebra"
        ])
        let delegateMock = DelegateMock()
        let sut = CurrenciesRepository(
            remoteStorage: remoteStorageMock,
            delegate: delegateMock
        )

        // When
        await sut.load()

        // Then
        switch await sut.state {
        case .loaded(let items):
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items[0].sign, "XYZ")
            XCTAssertEqual(items[0].title, "XYZ")
            XCTAssertEqual(items[0].subtitle, "Xenomorph Yellow Zebra")
            XCTAssertEqual(items[0].isSelected, false)
        default: XCTFail()
        }
    }

    func testToggle() async throws {
        // Given
        let remoteStorageMock = RemoteStorageMock()
        remoteStorageMock.getCurrenciesResult = .success([
            "ABC": "Amazing Bussiness Currency",
            "XYZ": "Xenomorph Yellow Zebra"
        ])
        let delegateMock = DelegateMock()
        let sut = CurrenciesRepository(
            remoteStorage: remoteStorageMock,
            delegate: delegateMock
        )

        // When
        await sut.load()
        let state = await sut.state
        guard case .loaded(let currencies) = state, !currencies.isEmpty else {
            XCTFail()
            return
        }
        await sut.toggle(currencies.first!)

        // Then
        switch await sut.state {
        case .loaded(let items):
            XCTAssertEqual(items[0].isSelected, true)
        default:
            XCTFail()

        }
    }
}

private final class DelegateMock: CurrenciesRepositoryDelegate {
    func selectedCurrencies() async -> [String] {
        ["ABC"]
    }
    
    func onComplete(_ addedCurrencies: [Rates.CurrencyItem]) {}
}
