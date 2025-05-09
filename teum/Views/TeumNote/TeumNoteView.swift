//
//  TeumNoteView.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import SwiftUI

struct TeumNoteView: View {
    @EnvironmentObject var coordinator: AppCoordinator<Destination>
    @State private var myNotes: [Note] = []
    @State private var flippedStates: [String: Bool] = [:]

    var body: some View {
        VStack {
            CustomHeaderView(title: "틈 노트")
            ZStack(alignment: .bottomTrailing) {
                myNoteList()
                floatingButton()
            }
        }
        .task {
            do {
                let data = try await FireStoreManager.shared.fetchMyNotes()
                myNotes = data
                flippedStates = Dictionary(uniqueKeysWithValues: data.compactMap {
                    guard let id = $0.id else { return nil }
                    return (id, false)
                })
            } catch {
                pprint("Error fetching notes: \(error.localizedDescription)")
            }
        }
    }

    private func bindingForNoteFlip(id: String) -> Binding<Bool> {
        return Binding(
            get: { flippedStates[id] ?? false },
            set: { flippedStates[id] = $0 }
        )
    }

    private func myNoteList() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(myNotes, id: \ .id) { note in
                    if let id = note.id {
                        FlipCard(
                            flipped: bindingForNoteFlip(id: id),
                            note: note
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    private func floatingButton() -> some View {
        Button {
            self.coordinator.push(.TeumNoteWrite)
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
