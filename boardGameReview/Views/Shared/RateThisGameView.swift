//
//  RateThisGameView.swift
//  boardGameReview
//
//  Created by Robert Fusting on 12/7/25.
//

import SwiftUI

struct RateThisGameView: View {
    @Binding var isPresented: Bool
    var body: some View {
        ZStack {
            Button {
                withAnimation(.spring()) {
                    isPresented = true
                }
            } label: {
                HStack {
                    Text("Rate this game:")
                        .font(.system(size:13))
                        .foregroundStyle(Color("MutedText"))
                    FlexStarsView(rating:.constant(0), size: 13, interactive: false)
                }
            }
        }
    }
}


#Preview {
    RateThisGameView(isPresented: .constant(false))
    //AddStars(isPresented: .constant(true))
}
