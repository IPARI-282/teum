import SwiftUI

struct ArticleCardView: View {
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
                .lineLimit(2)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 160)
    }
}