//
//  TeumNoteView.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import SwiftUI

struct TeumNoteView: View {
    
    @State private var myNotes: [Note] = []
    @State private var navigateToWriteView = false  // TODO: 네비게이션 관리 필요
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                titleView()
                myNoteList()
                floatingButton()
            }
            .navigationDestination(isPresented: $navigateToWriteView) {
                TeumNoteWriteView()
            }
            .task {
                do {
                    let data = try await FireStoreManager.shared.fetchPublicNotes()
                    myNotes = data
                } catch {
                    pprint("Error fetching notes: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func titleView() -> some View {
        // TODO: 다른 화면 보고 디자인 맞춰야 함
        VStack {
            HStack {
                Text("내 노트")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal)
            Spacer()
        }
    }
    
    private func myNoteList() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(myNotes, id: \.id) { note in
                    FlipCard(flipped: .constant(false))
                        .onTapGesture {
                            // 카드 뒤집기 로직 추가 필요
                        }
                }
            }
        }
        .padding()
    }
    
    private func floatingButton() -> some View {
        Button {
            navigateToWriteView = true
        } label: {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Color.mainColor)
                .clipShape(Circle())
                .padding()
        }
        .padding(.bottom)
    }
    
}

#Preview {
    TeumNoteView()
}
