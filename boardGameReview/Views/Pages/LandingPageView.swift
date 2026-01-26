//
//  LandingPageView.swift
//  boardGameReview
//
//  Created by Robert Fusting on 1/19/26.
//

import SwiftUI

struct LandingPageView: View {
    var body: some View {
        ZStack {
            Image("LudioMobile")
                .resizable()
                .ignoresSafeArea()
            Button{} label: {
                Text("Join Now")
                    .foregroundStyle(Color.white)
                    .background(
                        Capsule()
                            .fill(Color("PrimaryButton"))
                            .frame(width: 200, height: 70)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    LandingPageView()
}
