import SwiftUI

struct PublicProfileView: View {
    let userId: String
    @StateObject private var vm: PublicProfileViewModel

    init(userId: String) {
        self.userId = userId
        _vm = StateObject(wrappedValue: PublicProfileViewModel(userId: userId))
    }

    var body: some View {
        NavigationStack {
            VStack {
                if let user = vm.profileUser {
                    HStack(spacing: 16) {
                        AsyncImage(url: user.photoURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.crop.circle")
                                .resizable()
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())

                        VStack(alignment: .leading) {
                            Text(user.displayName)
                                .font(.title2)
                                .bold()
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button(action: vm.toggleFollow) {
                            Text(vm.isFollowing ? "Unfollow" : "Follow")
                                .frame(minWidth: 80)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ProgressView()
                        .padding()
                }
                
                // Followers / Following badges
                HStack(spacing: 32) {
                    NavigationLink(
                        destination: UserListView(userId: userId, isFollowers: true)
                    ) {
                        VStack {
                            Text("\(vm.followersCount)")
                                .font(.headline)
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    NavigationLink(
                        destination: UserListView(userId: userId, isFollowers: false)
                    ) {
                        VStack {
                            Text("\(vm.followingCount)")
                                .font(.headline)
                            Text("Following")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                Divider()

                if vm.posts.isEmpty {
                    Spacer()
                    Text("No posts yet")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List(vm.posts) { post in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(post.title)
                                .font(.headline)
                            Text(post.workout.summary)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(vm.profileUser?.displayName ?? "Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PublicProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PublicProfileView(userId: "exampleId")
    }
}
