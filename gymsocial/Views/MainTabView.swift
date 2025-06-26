//
//  MainTabView.swift
//  gymsocial
//
//  Created by Jakeb Milburn on 6/25/25.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "house")
                }

            CreatePostView()
                .tabItem {
                    Label("New Post", systemImage: "plus.square")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(SessionViewModel())
    }
}
