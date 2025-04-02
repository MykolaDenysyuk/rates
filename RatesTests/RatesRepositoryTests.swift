import XCTest
@testable import Rates

final class RatesRepositoryTests: XCTestCase {
    func testRefresh() async throws {
        // Given
        let remoteStorageMock = RemoteStorageMock()
        remoteStorageMock.getRatesResult = .success([
            "ABC" : 0.25
        ])
        let localStorageMock = LocalStorageMock()
        localStorageMock.fetchResult = [
            RateDataModel(sign: "XYZ", title: "XYZ", rate: 10, timestamp: Date()),
            RateDataModel(sign: "ABC", title: "ABC", rate: 20, timestamp: Date())
        ]
        let sut = RatesRepository(localStorage: localStorageMock, remoteStorage: remoteStorageMock)

        // When
        await sut.refresh()
        sut.dispose()

        // Then
        // - the resulting state contains the stored items with updated rates
        switch await sut.state {
        case .loaded(let rates):
            XCTAssertEqual(rates.count, 2)
            XCTAssertEqual(rates[0].rate, 0.25)
            XCTAssertEqual(rates[1].rate, 10)
        default:
            XCTFail()
        }

        // - the most recent rate has been stored
        switch localStorageMock.invocations.last {
        case .update(let model):
            XCTAssert((model as? RateDataModel)?.rate == 0.25)
        default:
            XCTFail()
        }
    }
}


