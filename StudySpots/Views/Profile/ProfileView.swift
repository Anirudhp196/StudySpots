import SwiftUI
import SwiftData

private enum ProfileTab: String, CaseIterable {
    case been = "Been"
    case saved = "Saved"
}

struct ProfileView: View {

    @Query private var profiles: [UserProfile]
    @Query private var allSpots: [StudySpot]
    @Query(filter: #Predicate<Review> { $0.isOwnReview }) private var myReviews: [Review]

    @State private var showSetup = false
    @State private var showEditName = false
    @State private var selectedTab: ProfileTab = .been

    private var profile: UserProfile? { profiles.first }
    private var bookmarkedSpots: [StudySpot] { allSpots.filter(\.isBookmarked) }
    private var visitedSpots: [StudySpot] {
        allSpots.filter { spot in spot.reviews.contains { $0.isOwnReview } }
    }
    private var avgRatingGiven: Double? {
        guard !myReviews.isEmpty else { return nil }
        return myReviews.map(\.rating).reduce(0, +) / Double(myReviews.count)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    profileHeader
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section {
                    statsGrid
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section {
                    Picker("Tab", selection: $selectedTab) {
                        ForEach(ProfileTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowBackground(Color.clear)
                }

                switch selectedTab {
                case .been:
                    beenSection
                case .saved:
                    savedSection
                }
            }
            .navigationTitle("Profile")
            .navigationDestination(for: StudySpot.self) { spot in
                SpotDetailView(spot: spot)
            }
            .sheet(isPresented: $showSetup) {
                ProfileSetupView()
            }
            .sheet(isPresented: $showEditName) {
                if let profile { EditNameView(profile: profile) }
            }
            .onAppear {
                if profile == nil { showSetup = true }
            }
        }
    }

    // MARK: - Sections

    @ViewBuilder
    private var beenSection: some View {
        if visitedSpots.isEmpty {
            Section {
                emptyState(
                    icon: "checkmark.seal",
                    title: "No spots visited yet",
                    subtitle: "Write a review on any spot and it'll appear here."
                )
            }
        } else {
            Section("\(visitedSpots.count) spot\(visitedSpots.count == 1 ? "" : "s") visited") {
                ForEach(visitedSpots) { spot in
                    NavigationLink(value: spot) {
                        VisitedSpotRow(spot: spot, myReviews: spot.reviews.filter(\.isOwnReview))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var savedSection: some View {
        if bookmarkedSpots.isEmpty {
            Section {
                emptyState(
                    icon: "bookmark.slash",
                    title: "No saved spots yet",
                    subtitle: "Tap the bookmark icon on any spot."
                )
            }
        } else {
            Section("\(bookmarkedSpots.count) spot\(bookmarkedSpots.count == 1 ? "" : "s") saved") {
                ForEach(bookmarkedSpots) { spot in
                    NavigationLink(value: spot) {
                        BookmarkedSpotRow(spot: spot)
                    }
                }
            }
        }
    }

    // MARK: - Header & Stats

    private var profileHeader: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [.blue.opacity(0.7), .blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Edit button
            Button {
                if profile != nil { showEditName = true } else { showSetup = true }
            } label: {
                Image(systemName: profile != nil ? "pencil.circle.fill" : "person.crop.circle.badge.plus")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .padding(12)

            // Avatar + name at bottom
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: 72, height: 72)
                    Text(profile?.initials ?? "?")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile?.name ?? "Set up your profile")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                    if profile != nil {
                        Text("StudySpots member")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(height: 140)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var statsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12
        ) {
            StatTileView(value: "\(visitedSpots.count)", label: "Been To",
                         icon: "checkmark.seal.fill", color: .green)
            StatTileView(value: "\(bookmarkedSpots.count)", label: "Saved",
                         icon: "bookmark.fill", color: .purple)
            StatTileView(
                value: avgRatingGiven.map { String(format: "%.1f", $0) } ?? "—",
                label: "Avg Rating", icon: "star.fill", color: .yellow
            )
        }
        .padding(.horizontal)
        .padding(.bottom, 4)
    }

    private func emptyState(icon: String, title: String, subtitle: String) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.subheadline).foregroundStyle(.secondary)
                Text(subtitle)
                    .font(.caption).foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical)
            Spacer()
        }
    }
}

// MARK: - Edit Name Sheet

struct EditNameView: View {
    let profile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name: String

    init(profile: UserProfile) {
        self.profile = profile
        _name = State(initialValue: profile.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Name") {
                    TextField("Name", text: $name).autocorrectionDisabled()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        profile.name = name.trimmingCharacters(in: .whitespaces)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Row Views

struct VisitedSpotRow: View {
    let spot: StudySpot
    let myReviews: [Review]

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title3)
                .foregroundStyle(.green)
                .frame(width: 40, height: 40)
                .background(.green.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(spot.name)
                    .font(.headline).lineLimit(1)
                if let last = myReviews.sorted(by: { $0.timestamp > $1.timestamp }).first {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow).font(.caption2)
                        Text("You rated \(String(format: "%.1f", last.rating))")
                            .font(.caption).foregroundStyle(.secondary)
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(last.timestamp.formatted(.relative(presentation: .named)))
                            .font(.caption).foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }
}

struct StatTileView: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.title2.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

struct BookmarkedSpotRow: View {
    let spot: StudySpot

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.title3).foregroundStyle(.blue)
                .frame(width: 40, height: 40)
                .background(.blue.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(spot.name).font(.headline).lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption2)
                    Text(spot.averageRating > 0
                         ? String(format: "%.1f", spot.averageRating) : "No ratings")
                        .font(.caption).foregroundStyle(.secondary)
                    Text("·").foregroundStyle(.secondary)
                    Text("\(spot.reviews.count) reviews").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [StudySpot.self, Review.self, UserProfile.self], inMemory: true)
}
