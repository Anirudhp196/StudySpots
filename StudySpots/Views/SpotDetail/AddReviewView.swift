// Sheet for writing or editing a review with fields for rating, noise, crowd, and notes.
import SwiftUI
import SwiftData

struct AddReviewView: View {

    let spot: StudySpot
    let existingReview: Review?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var profiles: [UserProfile]

    @State private var authorName: String
    @State private var rating: Double
    @State private var noiseLevel: NoiseLevel
    @State private var crowdDensity: CrowdDensity
    @State private var notes: String

    private var profile: UserProfile? { profiles.first }
    private var isEditing: Bool { existingReview != nil }

    private var isValid: Bool {
        !authorName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(spot: StudySpot, existingReview: Review? = nil) {
        self.spot = spot
        self.existingReview = existingReview
        _rating = State(initialValue: existingReview?.rating ?? 3.0)
        _noiseLevel = State(initialValue: existingReview?.noiseLevel ?? .moderate)
        _crowdDensity = State(initialValue: existingReview?.crowdDensity ?? .moderate)
        _notes = State(initialValue: existingReview?.notes ?? "")
        _authorName = State(initialValue: existingReview?.authorName ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                if profile == nil {
                    Section("Your Name") {
                        TextField("e.g. Alex R.", text: $authorName)
                    }
                } else {
                    Section {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(.blue.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Text(profile!.initials)
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.blue)
                            }
                            Text(profile!.name)
                                .font(.subheadline.weight(.medium))
                        }
                    } header: {
                        Text("Posting as")
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Rating")
                            Spacer()
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { i in
                                    Image(systemName: starIcon(for: i, rating: rating))
                                        .foregroundStyle(.yellow)
                                }
                            }
                            Text(String(format: "%.1f", rating))
                                .font(.subheadline.weight(.semibold))
                                .frame(width: 30)
                        }
                        Slider(value: $rating, in: 1...5, step: 0.5)
                            .tint(.yellow)
                    }
                } header: {
                    Text("Rating")
                }

                Section("Environment") {
                    Picker("Noise Level", selection: $noiseLevel) {
                        ForEach(NoiseLevel.allCases, id: \.self) { level in
                            Label(level.rawValue, systemImage: level.icon)
                                .tag(level)
                        }
                    }
                    Picker("Crowd Density", selection: $crowdDensity) {
                        ForEach(CrowdDensity.allCases, id: \.self) { density in
                            Label(density.rawValue, systemImage: density.icon)
                                .tag(density)
                        }
                    }
                }

                Section("Notes (optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(isEditing ? "Edit Review" : "Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Submit") { submitReview() }
                        .disabled(!isValid)
                }
            }
            .onAppear {
                if existingReview == nil, let profile {
                    authorName = profile.name
                }
            }
        }
    }

    private func submitReview() {
        if let existing = existingReview {
            existing.rating = rating
            existing.noiseLevel = noiseLevel
            existing.crowdDensity = crowdDensity
            existing.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            try? modelContext.save()
        } else {
            let review = Review(
                authorName: authorName.trimmingCharacters(in: .whitespaces),
                rating: rating,
                noiseLevel: noiseLevel,
                crowdDensity: crowdDensity,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                isOwnReview: profile != nil
            )
            review.spot = spot
            modelContext.insert(review)
            spot.visitCount += 1
            try? modelContext.save()
        }
        dismiss()
    }

    private func starIcon(for index: Int, rating: Double) -> String {
        if Double(index) <= rating { return "star.fill" }
        if Double(index) - 0.5 <= rating { return "star.leadinghalf.filled" }
        return "star"
    }
}
