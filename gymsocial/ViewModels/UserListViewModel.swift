//
//  UserListViewModel.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 8/6/25.
//


import Foundation
import Combine

final class UserListViewModel: ObservableObject {
    let userId: String
    let isFollowers: Bool

    @Published var users: [User] = []
    @Published var errorMessage: String?

    init(userId: String, isFollowers: Bool) {
        self.userId = userId
        self.isFollowers = isFollowers
        fetch()
    }

    func fetch() {
        let service = DatabaseService.shared
        let completion: (Result<[User], Error>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let found):
                    self?.users = found
                    self?.errorMessage = nil
                case .failure(let err):
                    self?.users = []
                    self?.errorMessage = err.localizedDescription
                }
            }
        }
        if isFollowers {
            service.fetchFollowers(for: userId, completion: completion)
        } else {
            service.fetchFollowing(for: userId, completion: completion)
        }
    }
}
