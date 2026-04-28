// Wraps SpotCardView with a horizontal swipe gesture to bookmark or unbookmark a spot.
import SwiftUI
import SwiftData

struct SwipeableSpotCard: View {

    let spot: StudySpot
    let distanceLabel: String?

    @Environment(\.modelContext) private var modelContext
    @State private var offset: CGFloat = 0
    @State private var triggered = false

    private let threshold: CGFloat = 72

    var body: some View {
        ZStack(alignment: .leading) {
            revealBackground
            SpotCardView(spot: spot, distanceLabel: distanceLabel)
                .offset(x: offset)
                .gesture(swipeGesture)
                .sensoryFeedback(.impact(flexibility: .soft), trigger: triggered)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var revealBackground: some View {
        let bookmarked = spot.isBookmarked
        let color: Color = bookmarked ? .red : .blue

        return HStack(spacing: 0) {
            ZStack {
                color.opacity(0.15)
                VStack(spacing: 4) {
                    Image(systemName: bookmarked ? "bookmark.slash.fill" : "bookmark.fill")
                        .font(.title2)
                        .foregroundStyle(color)
                        .scaleEffect(triggered ? 1.25 : 1.0)
                        .animation(.spring(response: 0.2), value: triggered)
                    Text(bookmarked ? "Remove" : "Save")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(color)
                }
            }
            .frame(width: max(0, offset))

            Spacer()
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onChanged { value in
                let h = value.translation.width
                let v = value.translation.height
                guard abs(h) > abs(v), h > 0 else { return }

                withAnimation(.interactiveSpring(response: 0.3)) {
                    offset = h
                }

                let shouldTrigger = h >= threshold
                if shouldTrigger != triggered {
                    triggered = shouldTrigger
                }
            }
            .onEnded { value in
                let h = value.translation.width
                if abs(h) > abs(value.translation.height), triggered {
                    toggleBookmark()
                }
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    offset = 0
                }
                triggered = false
            }
    }

    private func toggleBookmark() {
        spot.isBookmarked.toggle()
        try? modelContext.save()
    }
}
