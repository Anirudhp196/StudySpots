import SwiftUI
import SwiftData
import MapKit

struct SpotDetailView: View {

    let spot: StudySpot
    @Environment(LocationViewModel.self) private var locationVM
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showAddReview = false
    @State private var reviewToEdit: Review? = nil
    @State private var showDeleteSpotAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Full-width map header
                miniMap
                    .frame(height: 220)

                // Core info
                VStack(alignment: .leading, spacing: 20) {
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
                HStack(spacing: 14) {
                    if spot.isUserAdded {
                        Button(role: .destructive) {
                            showDeleteSpotAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                    Button {
                        spot.isBookmarked.toggle()
                        try? modelContext.save()
                    } label: {
                        Image(systemName: spot.isBookmarked ? "bookmark.fill" : "bookmark")
                            .symbolEffect(.bounce, value: spot.isBookmarked)
                            .foregroundStyle(spot.isBookmarked ? .blue : .primary)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            addReviewButton
        }
        .sheet(isPresented: $showAddReview) {
            AddReviewView(spot: spot)
        }
        .sheet(item: $reviewToEdit) { review in
            AddReviewView(spot: spot, existingReview: review)
        }
        .alert("Delete Spot?", isPresented: $showDeleteSpotAlert) {
            Button("Delete", role: .destructive) { deleteSpot() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently remove \"\(spot.name)\" and all its reviews.")
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
            if spot.isUserAdded {
                Label("Added by you", systemImage: "person.crop.circle.badge.checkmark")
                    .font(.caption)
                    .foregroundStyle(.green)
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
            HStack {
                Text("Reviews")
                    .font(.title3.weight(.semibold))
                Spacer()
                if !spot.reviews.isEmpty {
                    Text("\(spot.reviews.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            if spot.reviews.contains(where: \.isOwnReview) {
                Label("Hold your review to edit or delete it", systemImage: "hand.tap")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

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
                        .padding()
                        .background(.secondary.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .contextMenu {
                            if review.isOwnReview {
                                Button {
                                    reviewToEdit = review
                                } label: {
                                    Label("Edit Review", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    deleteReview(review)
                                } label: {
                                    Label("Delete Review", systemImage: "trash")
                                }
                            }
                        }
                }
            }
        }
    }

    private func deleteReview(_ review: Review) {
        if review.isOwnReview { spot.visitCount = max(0, spot.visitCount - 1) }
        modelContext.delete(review)
        try? modelContext.save()
    }

    private func deleteSpot() {
        modelContext.delete(spot)
        try? modelContext.save()
        dismiss()
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                // Author avatar
                ZStack {
                    Circle()
                        .fill(review.isOwnReview ? .blue.opacity(0.15) : .secondary.opacity(0.1))
                        .frame(width: 34, height: 34)
                    Text(initials(for: review.authorName))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(review.isOwnReview ? .blue : .secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(review.authorName)
                            .font(.subheadline.weight(.semibold))
                        if review.isOwnReview {
                            Text("You")
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.12))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    Text(review.timestamp.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", review.rating))
                        .font(.subheadline.weight(.bold))
                }
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
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.prefix(2).compactMap { $0.first }.map(String.init).joined()
    }
}
