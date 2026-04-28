// First-run sheet that asks the user to enter their name before using the app.
import SwiftUI
import SwiftData

struct ProfileSetupView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.15))
                            .frame(width: 90, height: 90)
                        Text(initialsPreview)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.blue)
                    }

                    Text("Create your profile")
                        .font(.title2.weight(.semibold))
                    Text("Your name appears on reviews you write.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                Form {
                    Section("Your Name") {
                        TextField("e.g. Alex R.", text: $name)
                            .autocorrectionDisabled()
                    }
                }
                .scrollDisabled(true)
                .frame(maxHeight: 120)
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!isValid)
                }
            }
            .interactiveDismissDisabled()
        }
    }

    private var initialsPreview: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        guard !letters.isEmpty else { return "?" }
        return String(letters).uppercased()
    }

    private func save() {
        let profile = UserProfile(name: name.trimmingCharacters(in: .whitespaces))
        modelContext.insert(profile)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    ProfileSetupView()
        .modelContainer(for: [UserProfile.self], inMemory: true)
}
