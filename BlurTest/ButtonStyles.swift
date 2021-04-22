//
//  ButtonStyles.swift
//  BlurTest
//
//  Created by Edward Luo on 2021-04-21.
//

import Foundation
import SwiftUI

struct HugeButtonStyle: ButtonStyle {
    var bgColor: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label
                .padding()
                .foregroundColor(Color(.systemBackground))
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(bgColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color.white)
                .opacity(configuration.isPressed ? 0.5 : 0)
        )
        .scaleEffect(configuration.isPressed ? 0.95: 1)
        .animation(.spring())
    }
}
