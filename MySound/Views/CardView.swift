//
//  CardView.swift
//  MySound
//
//  Created by apple on 2/16/26.
//

import SwiftUI

struct CardView: View {
    let text: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(radius: 8)

            Text(text)
                .font(.system(size: 42, weight: .bold))
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(width: 340, height: 420)
    }
}

#Preview {
    CardView(text: "Brother")
}
