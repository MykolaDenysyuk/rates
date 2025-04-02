enum ContentState<DataType> {
    case empty
    case loading
    case refreshing(DataType)
    case loaded(DataType)
    case error(AppError)
}

extension ContentState {
    var isLoading: Bool {
        switch self {
        case .loading, .refreshing:
            return true
        default:
            return false
        }
    }

    func toLoading() -> Self {
        switch self {
        case .empty, .loading, .error:
            return .loading
        case .refreshing(_):
            return self
        case .loaded(let data):
            return .refreshing(data)        
        }
    }
}
