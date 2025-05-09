//
//  CommunityView.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var coordinator: AppCoordinator<Destination>
    @StateObject var viewModel = CommunityViewModel(fireStoreManager: FireStoreManager.shared)
    
    var body: some View {
            VStack(spacing: 0) {
                CustomHeaderView(title: "틈 커뮤니티")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        trendingTeumNotes(trendingList: viewModel.trendingNotes)
                        teumListView(latestList: viewModel.latestNotes)
                    }
                }
            }
            .task {
                await viewModel.fetchNotes()
            }
            .padding(.bottom, 36)
            .navigationBarHidden(true)
        }
}

extension CommunityView {
    func trendingTeumNotes(trendingList: [Note]) -> some View {
        Section(header:
            Text("인기 틈 노트 📝")
                .font(.title3.bold())
                .padding(.horizontal)
        ) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(trendingList.enumerated()), id: \.element.id) { index, note in
                        RecentTeumNotes(rank: index + 1, note: note)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    func teumListView(latestList: [Note]) -> some View {
        Section(header:
            Text("최신 틈 노트 📝")
                .font(.title3.bold())
                .padding(.horizontal)
        ) {
            VStack {
                ForEach(latestList) { note in
                    teumNoteCardView(teumNote: note)
                }
            }
        }
    }
    
    func teumNoteCardView(teumNote: Note) -> some View {
        VStack(alignment: .leading, spacing: 12) {
    
            HStack(spacing: 8) {
                Image("AppIconPreview")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.nicknameRandom())
                        .font(.subheadline)
                        .bold()
                    Text(teumNote.district)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            Text(teumNote.title)
                .font(.headline)
                .bold()

            Text(teumNote.content.prefix(50) + "...")
                .font(.subheadline)
                .foregroundColor(.gray)

            if let imagePath = teumNote.imagePaths?.first,
               let url = URL(string: imagePath) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 200)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .frame(width: 300, height: 200)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct RecentTeumNotes: View {
    let rank: Int
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topLeading) {
                if let imagePath = note.imagePaths?.first,
                   let url = URL(string: imagePath) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 160, height: 160)
                    .clipped()
                    .cornerRadius(12)
                } else {
                    Image("AppIconPreview")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .clipped()
                        .cornerRadius(12)
                }

                Text("\(rank)")
                    .font(.headline)
                    .padding(6)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(8)
            }

            Text(note.title)
                .font(.headline)
                .lineLimit(1)

            Text(note.district)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 160)
    }
}

struct CustomHeaderView: View {
    let title: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.mainColor)

                Rectangle()
                    .frame(width: 48, height: 2)
                    .foregroundColor(.greenAurora)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(Color.white)
    }
}



extension UIApplication {
    static var safeAreaTop: CGFloat {
        // 현재 연결된 윈도우에서 top safeAreaInset 추출
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .safeAreaInsets.top ?? 0
    }
}
