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
    let review: ReviewModel?
    let text: String
    let onNavigate: () -> Void
    var body: some View {
        Button {
            onNavigate()
            router.push(.addReview(id: id, rating: rating, review: review))
        } label: {
            Text(text)
                .foregroundColor(Color.white)
            .padding()
            .padding(.horizontal, 70)
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color("MutedText"), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

