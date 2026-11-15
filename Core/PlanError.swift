import Foundation

public enum PlanError: Error, LocalizedError, Equatable {
    case invalid(String)
    public var errorDescription: String? { switch self { case .invalid(let text): return text } }
}
