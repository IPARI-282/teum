//
//  CommunityView.swift
//  teum
//
//  Created by younwookim on 4/15/25.
//

import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var coordinator: AppCoordinator<Destination>
    var viewModel = CommunityViewModel(fireStoreManager: FireStoreManager.shared)
    
    var body: some View {
            VStack(spacing: 0) {
                CustomHeaderView(title: "틈 커뮤니티")
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        trendingTeumNotes()
                        teumListView(communityList: viewModel.communityList)

                    }
                }
            }
            .task {
                await viewModel.fetchCommunityList()
            }
            .padding(.bottom, 36)
            .navigationBarHidden(true)
        }
}

extension CommunityView {
    func trendingTeumNotes() -> some View {
        Section(header:
            Text("인기 틈 노트 📝")
                .font(.title3.bold())
                .padding(.horizontal)
        ) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    RecentTeumNotes(rank: 1, imageName: "article1", title: "요즘 나한테 핫한 장소", subtitle: "손흥민")
                    
                    RecentTeumNotes(rank: 2, imageName: "article2", title: "정말 휴식이 필요할 때 추천합니다", subtitle: "박보영")
                }
                .padding(.horizontal)
            }
        }
    }
    
    func teumListView(communityList: [Note]) -> some View {
        Section(header:
            Text("최신 틈 노트 📝")
                .font(.title3.bold())
                .padding(.horizontal)
        ) {
            VStack {
                ForEach(viewModel.communityList) { note in
                    teumNoteCardView(teumNote: note)
                }
            }
        }
    }
    
    func teumNoteCardView(teumNote: Note) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(teumNote.id ?? "")
                        .font(.headline)
                    Text("@codewizard")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()
            }

            // MARK: 본문 텍스트
            Text(teumNote.content)
                .font(.body)
                .lineSpacing(4)

            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct RecentTeumNotes: View {
    let rank: Int
    let imageName: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.pink.opacity(0.4)) // 임시 배경
                    .frame(width: 160, height: 160)
                    .cornerRadius(12)

                Text("\(rank)")
                    .font(.headline)
                    .padding(6)
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(8)
            }

            Text(title)
                .font(.headline)
                .lineLimit(1)

            Text(subtitle)
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
