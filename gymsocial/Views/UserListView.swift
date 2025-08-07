//
//  UserListView.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 8/6/25.
//


import SwiftUI

struct UserListView: View {
    @StateObject private var vm: UserListViewModel
    private let title: String

    init(userId: String, isFollowers: Bool) {
        _vm = StateObject(wrappedValue: UserListViewModel(userId: userId, isFollowers: isFollowers))
        self.title = isFollowers ? "Followers" : "Following"
    }

    var body: some View {
        List(vm.users, id: \.id) { user in
            NavigationLink(destination: PublicProfileView(userId: user.id)) {
                HStack(spacing: 12) {
                    AsyncImage(url: user.photoURL) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                    Text(user.displayName)
                        .font(.body)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            Group {
                if let err = vm.errorMessage {
                    Text(err)
                        .foregroundColor(.red)
                        .padding()
                }
            },
            alignment: .center
        )
    }
}
