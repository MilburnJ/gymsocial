import SwiftUI

struct SearchView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = SearchViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search users…", text: $vm.query, onCommit: vm.search)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                if let error = vm.fetchError {
                    Text("Error fetching users: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                if vm.users.isEmpty {
                    Spacer()
                    Text(vm.query.isEmpty
                         ? "No users available."
                         : "No results for \"\(vm.query)\"")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List(vm.users) { user in
                        NavigationLink(destination: PublicProfileView(userId: user.id)) {
                            HStack {
                                AsyncImage(url: user.photoURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.crop.circle")
                                        .resizable()
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())

                                VStack(alignment: .leading) {
                                    Text(user.displayName)
                                        .font(.headline)
                                    Text(user.email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(SessionViewModel())
    }
}
