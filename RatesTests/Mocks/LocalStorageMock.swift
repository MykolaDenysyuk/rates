import Foundation
import SwiftData
@testable import Rates

final class LocalStorageMock: LocalStorageProtocol {
    enum Invocation {
        case add(any PersistentModel)
        case delete(any PersistentModel)
        case fetch
        case update(any PersistentModel)
    }

    private(set) var invocations: [Invocation] = []

    func add<Model>(_ newModel: Model) throws where Model : PersistentModel {
        invocations.append(.add(newModel))
    }
    
    func delete<Model>(_ model: Model) throws where Model : PersistentModel {
        invocations.append(.delete(model))
    }

    var fetchResult: [any PersistentModel] = []
    func fetch<Model>() async throws(Rates.AppError) -> [Model] where Model : PersistentModel {
        invocations.append(.fetch)
        return fetchResult as? [Model] ?? []
    }
    
    func update<Model>(_ model: Model) async throws(Rates.AppError) where Model : PersistentModel {
        invocations.append(.update(model))
    }
}
