// Views/ProfileView.swift

import SwiftUI
import PhotosUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var session: SessionViewModel
    @StateObject private var vm = ProfileViewModel()
    
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // — Profile Header (pic + name/email) —
            HStack(spacing: 12) {
                Group {
                    if let image = vm.profileImage {
                        Image(uiImage: image).resizable()
                    } else if let url = vm.user?.photoURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:    ProgressView()
                            case .success(let img): img.resizable()
                            case .failure:  Image(systemName: "person.crop.circle").resizable()
                            @unknown default: EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill").resizable()
                    }
                }
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                .onTapGesture { showPicker = true }

                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.user?.displayName
                         ?? session.currentUser?.displayName
                         ?? "Unknown User")
                        .font(.title3).bold()
                    Text(vm.user?.email
                         ?? session.currentUser?.email
                         ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            // — Muscle Diagram (last‑48h highlights) —
            MuscleDiagramView(highlight: vm.recentHighlighted)
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 180)
                .padding(.vertical, 4)

            Divider()

            // — Workout History —
            if vm.workouts.isEmpty {
                Text("No workouts logged yet")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.horizontal)
            } else {
                List(vm.workouts) { post in
                    NavigationLink {
                        WorkoutDetailView(post: post)
                    } label: {
                        ProfileWorkoutRow(post: post)
                    }
                }
                .listStyle(PlainListStyle())
            }

            // — Sign Out —
            Button("Sign Out") {
                try? AuthService.shared.signOut()
            }
            .foregroundColor(.red)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.bottom)   // space for tab bar
        .onAppear {
            if let uid = session.currentUser?.id {
                vm.subscribe(userId: uid)
            }
        }
        .photosPicker(
            isPresented: $showPicker,
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedItem) { newItem in
            guard let item = newItem else { return }
            item.loadTransferable(type: Data.self) { result in
                if case .success(let data?) = result,
                   let uiImage = UIImage(data: data) {
                    vm.uploadProfileImage(uiImage)
                }
            }
        }
    }
}

private struct ProfileWorkoutRow: View {
    let post: Post

    private var dateText: String {
        post.timestamp.formatted(.dateTime.month().day().year())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(post.title)
                .font(.headline)
            if let desc = post.description, !desc.isEmpty {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            HStack {
                Text(dateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(post.workout.summary
                        .components(separatedBy: "\n")
                        .first ?? ""
                )
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
