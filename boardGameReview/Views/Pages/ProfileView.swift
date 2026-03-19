//
//  ProfileView.swift
//  boardGameReview
//
//  Created by Robert Fusting on 12/13/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject var profileViewModel = ProfileViewModel()
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var auth: Auth
    @State private var addFriendsPresented: Bool = false
    @State private var pendingFriendsPresented: Bool = false
    let userID: Int
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Text(auth.username ?? "Loading...")
                        .padding(.trailing, 60)
                        .padding(.bottom, -5)
                        .padding(.top)
                    Spacer()
                    if userID == auth.userID {
                        Button{
                            Task {
                                await profileViewModel.sendFriendRequest(userID: auth.userID ?? 0, friendID: userID, auth: auth)
                            }
                        } label: {
                            Text("Add Friend")
                        }
                            .padding(.trailing, 20)
                    } else {
                        HStack {
                            Button {
                                pendingFriendsPresented.toggle()
                            } label : {
                                Image(systemName: "person.crop.circle")
                                    .overlay(alignment: .topTrailing) {
                                        if profileViewModel.pendingFriends.count > 0 {
                                            Text("\(profileViewModel.pendingFriends.count)")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.white)
                                                .padding(4)
                                                .background(Color.red)
                                                .clipShape(Circle())
                                                .offset(x: 6, y: -6)
                                        }
                                    }
                            }
                            Text("Life")
                                .padding(.trailing,20)
                        }
                    }
                }
                HStack(alignment: .center, spacing: 20) {
                    PhotosPicker(
                        selection: $profileViewModel.selectedItem,
                        maxSelectionCount: 1,
                        matching: .images
                    ) {
                        if profileViewModel.profileImageURL != nil {
                            AsyncImage(url: URL(string: profileViewModel.profileImageURL!)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                            .padding(.trailing, 20)
                        }
                        else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 75, height: 75)
                                .foregroundStyle(Color("MutedText"))
                                .padding(.trailing, 20)
                        }
                    }
                    .buttonStyle(.plain)
                    .onChange(of: profileViewModel.selectedItem) { oldValue, newValue in
                        Task {
                            await profileViewModel.handleImageChange(auth: auth)
                        }
                    }
                    VStack(spacing:3) {
                        Text(String(profileViewModel.gameNights.count))
                        Text("Posts")
                    }
                    Button {
                        addFriendsPresented.toggle()
                    } label: {
                        VStack(spacing:3) {
                            Text(String(profileViewModel.userFriends.count))
                            Text("Friends")
                        }
                    }.buttonStyle(.plain)
                    VStack(spacing:3) {
                        Text("50")
                        Text("Games Played")
                    }
                    
                }
                .padding(.horizontal)
            }
            VStack(alignment: .leading) {
                Text("Game nights")
                    .padding()
                    .padding(.bottom, -10)
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(maxWidth: .infinity, maxHeight: 1)
                gameNightImageGrid
                    .padding()
                Button {
                    router.push(.gameNightFeed(userOnly: true))
                } label : {
                    Text("See All")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(maxWidth: .infinity, maxHeight: 1)
                
                HStack {
                    Text("Games")
                    Spacer()
                    Text("Avg Win rate: 70%")
                }
                .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(profileViewModel.boardGames) {boardGame in
                            Button{
                                router.push(.boardGame(id: boardGame.id))
                            } label: {
                                AsyncImage(url: URL(string: boardGame.image ?? "")) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 180, height: 250)
                                .clipped()
                                .cornerRadius(5)
                            }
                        }
                    }
                }
                .padding()
                .onAppear() {
                    Task {
                        await profileViewModel.getUserFriends(userID: 1)
                        async let pendingFriends: () = profileViewModel.getUserFriendsPending(userID: auth.userID ?? 0, auth: auth)
                        await pendingFriends
                        async let boardGames: () = profileViewModel.fetchUserBoardGames(userID: userID)
                        async let gameNights: () = profileViewModel.fetchUserGameNights(userID: userID)
                        async let userProfile: () = profileViewModel.fetchUserProfile(auth: auth)
                        await userProfile
                        await boardGames
                        await gameNights
                        await withTaskGroup(of: Void.self) { group in
                            for gameNight in profileViewModel.gameNights {
                                let id = gameNight.id
                                let blobNames = gameNight.images ?? []
                                group.addTask {
                                    await profileViewModel.fetchImageURLFromBlob(id: id, blobNames: blobNames)
                                }
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $addFriendsPresented) {
                TagFriendsProfile(profileViewModel: profileViewModel, isPresented: $addFriendsPresented)
            }
            .fullScreenCover(isPresented: $pendingFriendsPresented) {
                PendingFriendsProfile(profileViewModel: profileViewModel, isPresented: $pendingFriendsPresented)
            }
        }
    }
    @ViewBuilder
    private var gameNightImageGrid: some View {
        let nights = Array(profileViewModel.gameNights.filter { profileViewModel.imageURLs[$0.id] != nil }.prefix(4))
        switch nights.count {
        case 1:
            HStack {
                gameNightImageTile(nights[0])
                Spacer()
            }
        case 2:
            HStack(spacing: 10) {
                gameNightImageTile(nights[0])
                gameNightImageTile(nights[1])
            }
        case 3:
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    gameNightImageTile(nights[0])
                    gameNightImageTile(nights[1])
                }
                HStack {
                    Spacer()
                    gameNightImageTile(nights[2])
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        case 4:
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    gameNightImageTile(nights[0])
                    gameNightImageTile(nights[1])
                }
                HStack(spacing: 10) {
                    gameNightImageTile(nights[2])
                    gameNightImageTile(nights[3])
                }
            }
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private func gameNightImageTile(_ gameNight: GameNightModel) -> some View {
        Button {} label: {
            VStack(alignment: .leading, spacing: 4) {
                if let imageURL = profileViewModel.imageURLs[gameNight.id] {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 150, height: 150)
                    .clipped()
                    .cornerRadius(5)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(gameNight.description ?? "")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 150, alignment: .center)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct PendingFriendsProfile: View {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject var profileViewModel : ProfileViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color("SoftOffWhite")
                .ignoresSafeArea()
            VStack {
                Button {
                    isPresented.toggle()
                
                } label: {
                    Text("Done")
                        .padding()
                }.frame(maxWidth: .infinity, alignment: .topTrailing)
            
                ScrollView {
                    ForEach(profileViewModel.pendingFriends) { friend in
                        Button {
                            router.push(.profile(id: friend.id))
                        } label: {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(.gray)
                                    .padding()
                                Text(friend.username)
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TagFriendsProfile: View {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject var profileViewModel : ProfileViewModel
    @Binding var isPresented: Bool
    @State var searchText: String = ""
    @State var taggedFriends: [String] = []
    
    var body : some View {
        ZStack {
            Color("SoftOffWhite")
                .ignoresSafeArea()
                VStack {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Text("Done")
                            .padding()
                        
                    } .frame(maxWidth: .infinity, alignment: .topTrailing)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .opacity(0.5)
                            .padding(.leading, 8)
                            .padding(.vertical, 6)
                        Button {} label: {
                            TextField("Friends", text: $searchText)
                                .multilineTextAlignment(.leading)
                                .onChange(of: searchText) {
                                    profileViewModel.filterFriends(searchText: searchText)
                                }
                        }
                    }
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                    ScrollView {
                        ForEach(profileViewModel.filteredFriends) { friend in
                            Button {
                                router.push(.profile(id: friend.id))
                            } label: {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.gray)
                                        .padding()
                                    Text(friend.username)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await profileViewModel.getUserFriends(userID: 1)
                }
            }
        }
}

#Preview {
    let auth = Auth()
    auth.setSession(AuthResponse(
        access_token: "preview-token",
        refresh_token: "preview-refresh",
        token_type: "bearer",
        user: RegisterResponse(username: "previewUser", id: 2)
    ))
    return ProfileView(userID: 2)
        .environmentObject(auth)
        .environmentObject(AppRouter())
}
