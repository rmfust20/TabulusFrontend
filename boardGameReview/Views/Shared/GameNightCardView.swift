//
//  GameNightCardView.swift
//  boardGameReview
//
//  Created by Robert Fusting on 3/8/26.
//

import SwiftUI

struct GameNightCardView: View {
    let gameNight : GameNightModel
    let boardGames: [Int: [String]]
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
            if let images = gameNight.images {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(images, id: \.self) { urlString in
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
          
            if let images = boardGames[181] {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(images, id: \.self) { urlString in
                            AsyncImage(url: URL(string: urlString)) { image in
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
            .padding(.horizontal,15)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(lineWidth: 1)
                .fill(Color.gray)
        )
        .padding()
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
        ), boardGames: [181: ["https://cf.geekdo-images.com/t09C6AsUI_ApPp1wm6XH-A__imagepage@2x/img/ZXdalhNNwSbya2zWI7XvMyDmxOE=/fit-in/1800x1200/filters:strip_icc()/pic9437664.jpg", "https://cf.geekdo-images.com/OnNFPEHOFUcCcCwuJANZSA__itemrep@2x/img/sgZ4zVZ4gMKjKMly68lEK1tQuo8=/fit-in/492x600/filters:strip_icc()/pic8251132.jpg"]]
    )
}
