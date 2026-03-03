import SwiftUI

struct AddGameNightView: View {
    @State private var isPresented: Bool = false
    @State private var addFriendsPresented: Bool = false
    @State var selectedBoardGameID : Int? = nil
    @StateObject private var gameNightViewModel = GameNightViewModel()
    @State private var text : String = ""
    @State private var placeholderText: String = "What happened?"

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
                        AddGameView(boardGame: game, image: ImageCache.shared.getImage(for: game.id))
                            .onAppear() {
                                Task {
                                    await gameNightViewModel.updateImageCache(boardGame: game)
                                }
                            }
                    }
                    ZStack (alignment:.topLeading){
                        TextEditor(text: $text)
                            .frame(height: 200)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.5))
                            )
                            .padding()
                        if text.isEmpty {
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
                    
                    Button {} label:{
                        Text("Tag Friends")
                            .padding()
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(maxWidth: .infinity, maxHeight: 1)
                    
                    ImageSelection()
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
                    TagFriends()
                }
        }
    }
}

struct AddGameView: View {
    let boardGame: BoardGameModel
    @State var image: UIImage?
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
                        Button { } label: { Text("Add Winner(s)") }
                        Button { } label: { Text("Add Duration") }
                    }
                    .padding()
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(maxWidth: .infinity, maxHeight: 1)
            }
        }
    }
}

struct TagFriends: View {
    @State var searchText: String = ""
    @State var taggedFriends: [String] = []
    @StateObject var gameNightViewModel = GameNightViewModel()
    var body : some View {
        ZStack {
            Color("SoftOffWhite")
                .ignoresSafeArea()
                VStack {
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
                            TaggedFriendListView(friendName: friend.username, friendID : friend.id, onSelect: {
                                gameNightViewModel.addFriend(friend: friend)
                            })
                        }
                    }
                    Button {} label: {
                        Text("Done")
                            .padding()
                        
                    } .frame(maxWidth: .infinity, alignment: .trailing)
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
    @State var friendImage : UIImage?
    @State var friendName : String
    @State var friendID : Int
    @State var isSelected : Bool = false
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
    TagFriends()
}
