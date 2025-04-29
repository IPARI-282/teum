//
//  FlipCardView.swift
//  teum
//
//  Created by junehee on 4/23/25.
//

import SwiftUI

struct FlipCard: View {
    
    @Binding var flipped: Bool

    var body: some View {
        ZStack {
            if flipped {
                Text("Back")
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                Text("Front")
            }
        }
        .frame(width: 300, height: 400)
        .background(flipped ? .blue : .red)
        .cornerRadius(10)
        .onTapGesture {
            withAnimation {
                flipped.toggle()
            }
        }
        .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: -1, z: 0))
    }
    
}

#Preview {
    FlipCard(flipped: .constant(false))
}
