//
//  FlipCardView.swift
//  teum
//
//  Created by junehee on 4/23/25.
//

import SwiftUI

struct FlipCard: View {
    
    @Binding var flipped: Bool
    @Binding var front: String
    @Binding var back: String

    var body: some View {
        ZStack {
            if flipped {
                Text(front)
                    .foregroundStyle(Color.softLavender)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                Text(back)
                    .foregroundStyle(Color.midnightBlue)
            }
        }
        .frame(width: 300, height: 400)
        .background(flipped ? Color.midnightBlue : Color.softLavender)
        .cornerRadius(10)
        .onTapGesture {
            withAnimation {
                flipped.toggle()
            }
        }
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: -1, z: 0))
    }
    
}
