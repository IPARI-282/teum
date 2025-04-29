
import SwiftUI
// MARK: - Top Filter Buttons
struct FilterButtonsView: View {
    @Binding var selectedFilter: CongestionFilter 
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CongestionFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        NotificationCenter.default.post(name: .showCongestionLabels, object: filter)
                    }) {
                        VStack {
                            Circle()
                                .fill(filter.color.opacity(0.3))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: filter.icon)
                                        .foregroundColor(filter.color)
                                )
                            Text(filter.title)
                                .font(.caption)
                                .foregroundColor(selectedFilter == filter ? .primary : .gray)
                        }
                        .padding(.horizontal, 6)
                        .background(selectedFilter == filter ? Color.gray.opacity(0.2) : Color.clear)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 8)
        .background(Color.white)
    }
}
