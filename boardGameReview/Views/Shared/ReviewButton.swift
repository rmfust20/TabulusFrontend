//
//  ReviewButton.swift
//  boardGameReview
//
//  Created by Robert Fusting on 1/4/26.
//

import SwiftUI

struct ReviewButton: View {
    @EnvironmentObject private var router: AppRouter
    let id: Int
    let rating: Int?
    var body: some View {
        Button {
            router.push(.addReview(id: id, rating: rating))
        } label: {
            Text("Write a Review")
            .padding()
            .padding(.horizontal, 70)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color.black, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ReviewButton(id: 0, rating: nil)
}
