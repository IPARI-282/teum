//
//  TeumNoteView.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import SwiftUI

struct TeumNoteView: View {
    
    @State private var myNotes: [Note] = []
    @State private var showOptions = false
    @State private var navigateToWriteView = false
    @State private var flippedStates: [Bool] = []
    
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // 스크롤뷰
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(flippedStates.enumerated()), id: \.offset) { index, _ in
                            FlipCard(flipped: $flippedStates[index])
                                .onTapGesture {
                                    flippedStates[index].toggle()
                                }
                        }
                    }
                }
                .padding()
                
                // 플로팅 버튼
                if showOptions {
                    VStack(spacing: 12) {
                        Button(action: {
                            navigateToWriteView = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            navigateToWriteView = true
                        }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                    }
                    .offset(x: -5, y: 10)
                    .transition(.scale)
                }
                
                Button {
                    withAnimation { showOptions.toggle() }
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.mainColor)
                        .clipShape(Circle())
                        .padding()
                }
            }
            .navigationDestination(isPresented: $navigateToWriteView) {
                TeumNoteWriteView()
            }
            .onAppear {
                if flippedStates.count < 20 {
                    flippedStates = Array(repeating: false, count: 20)
                }
            }
        }
    }
    
}

#Preview {
    TeumNoteView()
}
