import SwiftUI

struct AddGameNightView: View {
    let userID: Int
    @State private var isPresented: Bool = false
    @State private var addFriendsPresented: Bool = false
    @State var selectedBoardGameID : Int? = nil
    @StateObject private var gameNightViewModel = GameNightViewModel()
    @State private var placeholderText: String = "What happened?"
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var auth : Auth
    @StateObject private var imageUploadViewModel = ImageUploadViewModel()

    var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Text("Add Game")
                            .padding()
                            
                    }
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(maxWidth: .infinity, maxHeight: 1)
                    ForEach(gameNightViewModel.selectedGames, id: \.id) { game in
                        AddGameView(boardGame: game,gameNightViewModel : gameNightViewModel, image: ImageCache.shared.getImage(for: game.id))
                            .onAppear() {
                                Task {
                                    await gameNightViewModel.updateImageCache(boardGame: game)
                                }
                            }
                    }
                    ZStack (alignment:.topLeading){
                        TextEditor(text: $gameNightViewModel.description)
                            .frame(height: 200)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5))
                            )
                            .padding()
                        if gameNightViewModel.description.isEmpty {
                            Text("What happened?")
                                .foregroundColor(.gray)
                                .opacity(0.7)
                                .padding(.top,40)
                                .padding(.leading,32)
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(maxWidth: .infinity, maxHeight: 1)
                    
                    Button {
                        addFriendsPresented.toggle()
                    } label:{
                        Text("Tag Friends")
                            .padding()
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(maxWidth: .infinity, maxHeight: 1)
                    
                    ImageSelection(
                        imageViewModel: imageUploadViewModel
                        
                    )
                        .padding()
                }
                .fullScreenCover(isPresented: $isPresented) {
                    SearchView(isPresented: $isPresented, selectedBoardGameID: $selectedBoardGameID)
                        .onChange(of: selectedBoardGameID) {
                            Task {
                                let game = await gameNightViewModel.fetchBoardGame(selectedBoardGameID ?? -1)
                                if let game {
                                    gameNightViewModel.selectedGames.append(game)
                                }
                                isPresented.toggle()
                            }
                    }
            }
                .fullScreenCover(isPresented: $addFriendsPresented) {
                    TagFriends(winnerCaller: nil, gameNightViewModel: gameNightViewModel, isPresented: $addFriendsPresented)
                }
        }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await imageUploadViewModel.uploadSelected(auth: auth)
                            await gameNightViewModel.uploadGameNight(
                                auth: auth, images: imageUploadViewModel.uploaded
                            )
                        }
                    } label : {
                        Text("Save")
                    }
                }
            }
    }
}

struct AddGameView: View {
    let boardGame: BoardGameModel
    @ObservedObject var gameNightViewModel : GameNightViewModel
    @State var image: UIImage?
    @State var addFriendsPresented: Bool = false
    @State var durationPresented: Bool = false
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Image(uiImage: image ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    
                    VStack(spacing: 60) {
                        Text("Winners: ")
                        Text("Playtime: ")
                    }
                    
                    VStack(spacing: 45) {
                        Button {
                            addFriendsPresented.toggle()
                        } label: {
                              if gameNightViewModel.selectedWinners[boardGame.id] != nil {
                                Text("Change Winner(s)")
                            }
                            else {
                                Text("Add Winner(s)")
                            }
                        }
                        Button {
                            durationPresented.toggle()
                        } label: {
                            if gameNightViewModel.gameNightDurations[boardGame.id] != nil {
                                Text("Change Duration")
                            } else {
                                Text("Add Duration")
                            }
                        }
                    }
                    .padding()
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(maxWidth: .infinity, maxHeight: 1)
            }
            AddDurationView(gameNightViewModel: gameNightViewModel, gameID : boardGame.id,isPresented: $durationPresented)
        }
        .fullScreenCover(isPresented: $addFriendsPresented) {
            TagFriends(winnerCaller: boardGame.id, gameNightViewModel: gameNightViewModel, isPresented: $addFriendsPresented)
        }
    }
}

struct AddDurationView: View {
    @ObservedObject var gameNightViewModel : GameNightViewModel
    let gameID : Int
    @Binding var isPresented: Bool
    var body: some View {
        if isPresented {
            ScrollView {
                LazyVStack(alignment: .center) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(maxWidth: .infinity, maxHeight: 1)
                    ForEach(1..<21, id: \.self) { index in
                        let time = (index * 30) / 60
                        let remainder = (index * 30) % 60
                        if time == 0 {
                            Button {
                                isPresented.toggle()
                                gameNightViewModel.gameNightDurations[gameID] = time + remainder
                            }label: {
                                Text("\(remainder) minutes")
                                    .padding(.horizontal)
                            }
                        }
                        else if time < 10 {
                            if remainder == 0 {
                                Button {
                                    isPresented.toggle()
                                    gameNightViewModel.gameNightDurations[gameID] = time + remainder
                                } label: {
                                    Text("\(time) hours")
                                        .padding(.horizontal)
                                }
                            }
                            else {
                                Button {
                                    isPresented.toggle()
                                    gameNightViewModel.gameNightDurations[gameID] = time + remainder
                                } label: {
                                    Text("\(time) hours \(remainder) minutes")
                                        .padding(.horizontal)
                                }
                            }
                        }
                        else {
                            Button {
                                isPresented.toggle()
                                gameNightViewModel.gameNightDurations[gameID] = time + remainder
                            } label: {
                                Text("\(time) hours +")
                                    .padding(.horizontal)
                            }
                        }
                        Rectangle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(maxWidth: .infinity, maxHeight: 1)
                    }
                }
            }
            .frame(height: 300)
            .background(
                Color("SoftOffWhite")
                )
        }
    }
}

struct TagFriends: View {
    let winnerCaller : Int?
    @ObservedObject var gameNightViewModel : GameNightViewModel
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
                            TextField("Tag Friends", text: $searchText)
                                .multilineTextAlignment(.leading)
                                .onChange(of: searchText) {
                                    gameNightViewModel.filterFriends(searchText: searchText)
                                }
                        }
                    }
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                    ScrollView {
                        ForEach(gameNightViewModel.filteredFriends) { friend in
                            TaggedFriendListView(winnerCaller: winnerCaller, friendName: friend.username, friendID : friend.id, isSelected: gameNightViewModel.handleIsSelected(friendID: friend.id, winnerCaller: winnerCaller),
                                                 onSelect: {
                                gameNightViewModel.resolveToggle(friend.id, winnerCaller: winnerCaller)
                            }
                            )
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await gameNightViewModel.getUserFriends(userID: 1)
                }
            }
        }
}

struct TaggedFriendListView: View {
    let winnerCaller: Int?
    @State var friendImage : UIImage?
    @State var friendName : String
    @State var friendID : Int
    @State var isSelected: Bool
    let onSelect : () -> Void
    var body: some View {
        HStack {
            /*
            Image(uiImage: friendImage ?? UIImage())
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
             */
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundStyle(.gray)
                .padding()
            Text(friendName)
            Spacer()
            Button {
                onSelect()
                isSelected.toggle()
            } label: {
                if isSelected {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.white)
                }
                if isSelected == false {
                    Text("Add")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                }
            }
            .background(
                Capsule()
                    .fill(Color.blue)
                    .opacity(0.9)
            )
            .padding(.trailing, 8)
        }
    }
}

#Preview {
    AddGameNightView(userID: 1)
}
