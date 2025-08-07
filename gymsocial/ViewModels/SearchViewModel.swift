import Foundation
import FirebaseFirestore
import Combine

final class SearchViewModel: ObservableObject {
    @Published var query: String = "" {
        didSet {
            if query.isEmpty {
                fetchDefault()
            }
        }
    }
    @Published var users: [User] = []
    @Published var fetchError: Error?

    init() {
        fetchDefault()
    }

    private func fetchDefault() {
        DatabaseService.shared.fetchUsers(limit: 5) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let found):
                    self.users = found
                    self.fetchError = nil
                case .failure(let err):
                    self.users = []
                    self.fetchError = err
                }
            }
        }
    }

    func search() {
        guard !query.isEmpty else { return }
        DatabaseService.shared.searchUsers(byName: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let found):
                    self.users = found
                    self.fetchError = nil
                case .failure(let err):
                    self.users = []
                    self.fetchError = err
                }
            }
        }
    }
}
