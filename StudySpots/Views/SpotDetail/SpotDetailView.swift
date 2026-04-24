import SwiftUI
import SwiftData
import MapKit

struct SpotDetailView: View {

    let spot: StudySpot
    @Environment(LocationViewModel.self) private var locationVM
    @Environment(\.modelContext) private var modelContext

    @State private var showAddReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Mini map header
                miniMap
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Core info
                VStack(alignment: .leading, spacing: 16) {
                    headerSection
                    statsRow
                    Divider()
                    reviewsSection
                }
                .padding()
            }
        }
        .navigationTitle(spot.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    spot.isBookmarked.toggle()
                    try? modelContext.save()
                } label: {
                    Image(systemName: spot.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(spot.isBookmarked ? .blue : .primary)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            addReviewButton
        }
        .sheet(isPresented: $showAddReview) {
            AddReviewView(spot: spot)
        }
    }

    // MARK: - Subviews

    private var miniMap: some View {
        Map(interactionModes: []) {
            Annotation(spot.name, coordinate: spot.coordinate) {
                Image(systemName: "book.fill")
                    .padding(8)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
        .mapStyle(.standard)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.red)
                Text(spot.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let dist = locationVM.formattedDistance(to: spot) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.blue)
                        .font(.caption)
                    Text(dist + " away")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            // Rating
            VStack(spacing: 4) {
                Text(spot.averageRating > 0
                     ? String(format: "%.1f", spot.averageRating)
                     : "—")
                    .font(.title.weight(.bold))
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: starIcon(for: i, rating: spot.averageRating))
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    }
                }
                Text("\(spot.reviews.count) review\(spot.reviews.count == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.yellow.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Noise
            VStack(spacing: 4) {
                Image(systemName: spot.dominantNoiseLevel?.icon ?? "speaker.slash.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text(spot.dominantNoiseLevel?.rawValue ?? "—")
                    .font(.subheadline.weight(.semibold))
                Text("Noise")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Crowd
            VStack(spacing: 4) {
                Image(systemName: spot.dominantCrowdDensity?.icon ?? "person.fill")
                    .font(.title2)
                    .foregroundStyle(.purple)
                Text(spot.dominantCrowdDensity?.rawValue ?? "—")
                    .font(.subheadline.weight(.semibold))
                Text("Crowd")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.purple.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reviews")
                .font(.title3.weight(.semibold))

            if spot.reviews.isEmpty {
                ContentUnavailableView(
                    "No Reviews Yet",
                    systemImage: "text.bubble",
                    description: Text("Be the first to review this spot!")
                )
                .padding(.vertical)
            } else {
                ForEach(spot.reviews.sorted(by: { $0.timestamp > $1.timestamp })) { review in
                    ReviewRowView(review: review)
                    Divider()
                }
            }
        }
    }

    private var addReviewButton: some View {
        Button {
            showAddReview = true
        } label: {
            Label("Write a Review", systemImage: "square.and.pencil")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }

    private func starIcon(for index: Int, rating: Double) -> String {
        if Double(index) <= rating { return "star.fill" }
        if Double(index) - 0.5 <= rating { return "star.leadinghalf.filled" }
        return "star"
    }
}

struct ReviewRowView: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.authorName)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", review.rating))
                        .font(.caption.weight(.medium))
                }
                Text(review.timestamp.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 8) {
                Label(review.noiseLevel.rawValue, systemImage: review.noiseLevel.icon)
                    .font(.caption)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())

                Label(review.crowdDensity.rawValue, systemImage: review.crowdDensity.icon)
                    .font(.caption)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(.purple.opacity(0.1))
                    .foregroundStyle(.purple)
                    .clipShape(Capsule())
            }

            if !review.notes.isEmpty {
                Text(review.notes)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 4)
    }
}
