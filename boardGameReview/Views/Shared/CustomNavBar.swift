//
//  CustomNavBar.swift
//  boardGameReview
//
//  Created by Robert Fusting on 1/4/26.
//

import SwiftUI

struct CustomNavBar: ViewModifier {
    @EnvironmentObject private var router: AppRouter
    let trailingTitle: Bool
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(Color("CharcoalBackground"), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { router.pop() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.black)
                            .frame(width: 34, height: 34)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
            }
    }
}

extension View {
    func customNavBar(trailingTitle: Bool = false) -> some View {
        self.modifier(CustomNavBar(trailingTitle: trailingTitle))
    }
}


