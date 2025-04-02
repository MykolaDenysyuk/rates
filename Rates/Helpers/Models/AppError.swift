import Foundation

enum AppError: LocalizedError {
    case invalidInput
    case networkFailure
    case unknownError(reason: Error?)

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid input provided."
        case .networkFailure:
            return "Network failure occurred."
        case .unknownError(reason: let reason):
            return reason?.localizedDescription ?? "An unknown error occurred."
        }
    }
}
