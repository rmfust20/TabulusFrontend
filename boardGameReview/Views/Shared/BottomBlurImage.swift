//
//  BottomBlurImage.swift
//  boardGameReview
//
//  Created by Robert Fusting on 1/19/26.
//

import SwiftUI

struct BottomBlurImage: View {
    let image: Image
    var blurRadius: CGFloat = 18          // how strong the blur gets at the bottom
    var blurHeight: CGFloat = 0.20        // bottom portion (0.20 = 20%)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Sharp base image
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                // Blurred overlay, only visible at the bottom via gradient mask
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .blur(radius: blurRadius)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 1.0 - blurHeight),
                                .init(color: .black, location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
        .clipped()
    }
}


#Preview {
    BottomBlurImage(image: Image("LandingImage"))
}
