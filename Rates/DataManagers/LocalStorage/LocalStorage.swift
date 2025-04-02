import SwiftData

/// Persistent storage handler interface
protocol LocalStorageProtocol {
    func add<Model: PersistentModel>(_ newModel: Model) throws
    func delete<Model: PersistentModel>(_ model: Model) throws
    func fetch<Model: PersistentModel>() async throws(AppError) -> [Model]
    func update<Model: PersistentModel>(_ model: Model) async throws(AppError)
}

final class LocalStorage: LocalStorageProtocol {
    private let container: ModelContainer

    private lazy var context = ModelContext(container)

    init(container: ModelContainer = SwiftDataHelper.sharedModelContainer) {
        self.container = container
    }

    func add<Model: PersistentModel>(_ newModel: Model) throws(AppError) {
        context.insert(newModel)
        do {
            try context.save()
        } catch {
            throw AppError.unknownError(reason: error)
        }
    }

    func delete<Model: PersistentModel>(_ model: Model) throws(AppError) {
        context.delete(model)
        do {
            try context.save()
        } catch {
            throw AppError.unknownError(reason: error)
        }
    }

    func fetch<Model: PersistentModel>() async throws(AppError) -> [Model] {
        do {
            return try context.fetch(FetchDescriptor<Model>())
        } catch {
            throw AppError.unknownError(reason: error)
        }
    }

    func update<Model: PersistentModel>(_ model: Model) async throws(AppError) {
        if (model.hasChanges) {
            do {
                try context.save()
            } catch {
                throw AppError.unknownError(reason: error)
            }
        }
    }
}

enum SwiftDataHelper {
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            RateDataModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
