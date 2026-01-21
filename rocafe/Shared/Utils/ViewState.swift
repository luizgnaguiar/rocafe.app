import Foundation

protocol StandardViewModel: ObservableObject {
    associatedtype DataType
    var viewState: ViewState<DataType> { get set }
}

/// A generic enum to represent the state of a view or a view model, especially for operations involving asynchronous data fetching or processing.
enum ViewState<T> {
    /// The initial or idle state.
    case idle
    
    /// The state while data is being loaded or processed.
    case loading
    
    /// The state when data has been loaded but the result is empty.
    case empty
    
    /// The state when the operation has failed.
    /// - Parameter error: The error that occurred.
    case error(Error)
    
    /// The state when the operation has succeeded.
    /// - Parameter data: The data or result of the operation.
    case success(T)
}

// Conformance to Equatable can be useful for testing and state comparison,
// assuming the associated types are also Equatable.
extension ViewState: Equatable where T: Equatable {
    static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.empty, .empty):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.success(let lhsData), .success(let rhsData)):
            return lhsData == rhsData
        default:
            return false
        }
    }
}
