//
//  GameNightCardView.swift
//  boardGameReview
//
//  Created by Robert Fusting on 3/8/26.
//

import SwiftUI

struct GameNightCardView: View {
    let gameNight : GameNightModel
    let imageService: ImageService = ImageService()
    let boardGames: [(Int,String)]
    @State private var gameNightImages: [String] = []
    var body: some View {
        VStack{
            HStack {
                Image("userProfile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                VStack {
                    Text("Robert Fusiting")
                    Text("May 9th 2001")
                }
                Spacer()
                Image(systemName: "ellipsis")
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal)
                if gameNightImages.count == 1, let urlString = gameNightImages.first {
                    AsyncImage(url: URL(string: urlString)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 230, height: 230)
                    .clipped()
                    .cornerRadius(5)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(gameNightImages, id: \.self) { urlString in
                                AsyncImage(url: URL(string: urlString)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 230, height: 230)
                                .clipped()
                                .cornerRadius(5)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            Rectangle()
                .fill(Color("WantToPlayButton"))
                .frame(maxWidth: .infinity, maxHeight: 30)
                .padding(.horizontal)
            
                if boardGames.count == 1, let item = boardGames.first {
                    AsyncImage(url: URL(string: item.1)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 180, height: 250)
                    .clipped()
                    .cornerRadius(5)
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(boardGames, id: \.0) { item in
                                AsyncImage(url: URL(string: item.1)) { image in
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
                    .padding()
                }
            Text(gameNight.description ?? "")
                .multilineTextAlignment(.leading)
                .onAppear {
                    print(boardGames)
                }
            HStack {
                Image("userProfile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    .padding(.horizontal, -15)
                
                Image("userProfile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    .padding(.horizontal,-15)
                
                Image("userProfile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                    .padding(.leading,-15)
                
                Text("liked this")
                Spacer()
                Text("5 Comments")
                
                
            }
            .padding(.horizontal,15)
            
            HStack {
                Button {
                    
                } label : {
                    Image(systemName: "hand.thumbsup")
                        .font(.title)
                }.buttonStyle(.plain)
                Spacer()
                Button {} label: {
                    Image(systemName: "text.bubble")
                        .font(.title)
                }.buttonStyle(.plain)
            }
            .padding()
        }
        .onAppear {
            Task {
                if let images = gameNight.images {
                    let trueImages = try? await imageService.getImageURLs(blobNames: images)
                    if let trueImages = trueImages {
                        gameNightImages = trueImages
                    }
                }
            }
        }
    }
}

#Preview {
    GameNightCardView(
        gameNight: GameNightModel(
            id: 0,
            host_user_id: 0,
            game_night_date: "2024-05-09T19:00:00Z",
            description: "Had a great time playing Catan with friends!",
            sessions: [
                GameNightSessionModel(board_game_id: 181, duration_minutes: 90, winners_user_id: [1,2]),
            ],
            images: ["https://www.moongiant.com/images/todays_moon_phase.jpg", "https://upload.wikimedia.org/wikipedia/commons/1/10/Supermoon_Nov-14-2016-minneapolis.jpg", "https://media.wired.com/photos/5c425dd1ce277c2cb23d5667/master/pass/Blood-Moon-586081787.jpg"],
            users: []
        ), boardGames: [(181, "https://cf.geekdo-images.com/Oem1TTtSgxOghRFCoyWRPw__original/img/Nu3eXPyOkhtnR3hhpUrtgqRMAfs=/0x0/filters:format(jpeg)/pic4916782.jpg")]
    )
}
