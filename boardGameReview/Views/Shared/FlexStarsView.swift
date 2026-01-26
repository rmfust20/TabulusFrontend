//
//  FlexStarsView.swift
//  boardGameReview
//
//  Created by Robert Fusting on 1/15/26.
//

import SwiftUI

struct FlexStarsView: View {
    @Binding var rating: Int
    let size : CGFloat
    var interactive: Bool
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<5) { index in
                Button {
                    let newRating = index + 1
                    rating = (rating == newRating) ? 0 : newRating
                    //TODO network call to update users ratings
                } label: {
                    Image(systemName: index < rating ? "star.fill" : "star")
                        .font(.system(size:size))
                        .foregroundStyle(index < rating ? .yellow : .gray)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Rate \(index + 1) star\(index == 0 ? "" : "s")")
            }
        }
        .allowsHitTesting(interactive)
    }
}

#Preview {
    FlexStarsView(rating: .constant(3), size: 20, interactive: true)
}
