import SwiftUI
import SwiftData

struct AddReviewView: View {

    let spot: StudySpot
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var authorName = ""
    @State private var rating: Double = 3.0
    @State private var noiseLevel: NoiseLevel = .moderate
    @State private var crowdDensity: CrowdDensity = .moderate
    @State private var notes = ""

    private var isValid: Bool {
        !authorName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Name") {
                    TextField("e.g. Alex R.", text: $authorName)
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
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        submitReview()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private func submitReview() {
        let review = Review(
            authorName: authorName.trimmingCharacters(in: .whitespaces),
            rating: rating,
            noiseLevel: noiseLevel,
            crowdDensity: crowdDensity,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        review.spot = spot
        modelContext.insert(review)
        spot.visitCount += 1
        try? modelContext.save()
        dismiss()
    }

    private func starIcon(for index: Int, rating: Double) -> String {
        if Double(index) <= rating { return "star.fill" }
        if Double(index) - 0.5 <= rating { return "star.leadinghalf.filled" }
        return "star"
    }
}
