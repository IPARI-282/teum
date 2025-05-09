//
//  FlipCardView.swift
//  teum
//
//  Created by junehee on 4/23/25.
//

import SwiftUI

struct FlipCard: View {
    @Binding var flipped: Bool
    let note: Note

    var body: some View {
        ZStack {
            frontView()
                .opacity(flipped ? 0 : 1)
                .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            
            backView()
                .opacity(flipped ? 1 : 0)
                .rotation3DEffect(.degrees(flipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: 300, height: 400)
        .cornerRadius(16)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.6)) {
                flipped.toggle()
            }
        }
    }

    @ViewBuilder
    private func frontView() -> some View {
        ZStack {
            imageLayer(url: note.imagePaths?.first, blurred: true)

            VStack(alignment: .leading, spacing: 8) {
                Text(note.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func backView() -> some View {
        imageLayer(url: note.imagePaths?.first)
    }

    @ViewBuilder
    private func imageLayer(url: String?, blurred: Bool = false) -> some View {
        if let url = url.flatMap(URL.init(string:)) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 400)
                    .clipped()
                    .if(blurred) {
                        $0.blur(radius: 12).overlay(Color.black.opacity(0.2))
                    }
            } placeholder: {
                Color.gray.opacity(0.2)
                    .frame(width: 300, height: 400)
            }
        } else {
            Color.gray.opacity(0.2)
                .frame(width: 300, height: 400)
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
