import Foundation
import Combine

final class PublicProfileViewModel: ObservableObject {
    let userId: String

    @Published var profileUser: User?
    @Published var isFollowing: Bool = false
    @Published var posts: [Post] = []
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0
    @Published var errorMessage: String?

    init(userId: String) {
        self.userId = userId
        loadProfile()
        fetchFollowState()
        fetchPosts()
        fetchFollowersCount()
        fetchFollowingCount()
    }

    func fetchFollowersCount() {
        DatabaseService.shared.fetchFollowers(for: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.followersCount = users.count
                case .failure:
                    self.followersCount = 0
                }
            }
        }
    }

    func fetchFollowingCount() {
        DatabaseService.shared.fetchFollowing(for: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.followingCount = users.count
                case .failure:
                    self.followingCount = 0
                }
            }
        }
    }
    
    private func loadProfile() {
        DatabaseService.shared.fetchUser(withId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.profileUser = user
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    func fetchFollowState() {
        DatabaseService.shared.isFollowing(userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let following):
                    self.isFollowing = following
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    func toggleFollow() {
        if isFollowing {
            DatabaseService.shared.unfollow(userId: userId) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.isFollowing = false
                    }
                }
            }
        } else {
            DatabaseService.shared.follow(userId: userId) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.isFollowing = true
                    }
                }
            }
        }
    }

    func fetchPosts() {
        DatabaseService.shared.fetchPosts(for: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let loaded):
                    self.posts = loaded
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
}
