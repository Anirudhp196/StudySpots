// Form for adding a new spot by typing an address or picking a pin on the map.
import SwiftUI
import SwiftData
import MapKit
internal import CoreLocation

struct AddSpotView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var address = ""
    @State private var coordinate: CLLocationCoordinate2D? = nil
    @State private var resolvedAddress = ""
    @State private var isGeocoding = false
    @State private var geocodeError: String? = nil
    @State private var showMapPicker = false

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && coordinate != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Spot Details") {
                    TextField("Name (e.g. Van Pelt Library)", text: $name)
                }

                Section {
                    HStack {
                        TextField("Address or place name", text: $address)
                            .autocorrectionDisabled()
                            .onSubmit { geocodeAddress() }

                        if isGeocoding {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Button("Search") { geocodeAddress() }
                                .disabled(address.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }

                    if let error = geocodeError {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    if let coord = coordinate {
                        Map(position: .constant(.region(MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                        )))) {
                            Annotation("", coordinate: coord) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .allowsHitTesting(false)

                        if !resolvedAddress.isEmpty {
                            Label(resolvedAddress, systemImage: "mappin")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            showMapPicker = true
                        } label: {
                            Label("Adjust on Map", systemImage: "map")
                                .font(.subheadline)
                        }
                    } else {
                        Button {
                            showMapPicker = true
                        } label: {
                            Label("Pick Location on Map", systemImage: "map.fill")
                        }
                    }
                } header: {
                    Text("Location")
                } footer: {
                    if coordinate == nil {
                        Text("Search by address or drop a pin on the map.")
                    }
                }
            }
            .navigationTitle("Add a Spot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addSpot() }
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showMapPicker) {
                MapLocationPickerView(coordinate: $coordinate, resolvedAddress: $resolvedAddress)
            }
        }
    }

    private func geocodeAddress() {
        guard !address.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        geocodeError = nil
        isGeocoding = true
        coordinate = nil

        CLGeocoder().geocodeAddressString(address) { placemarks, error in
            isGeocoding = false

            guard error == nil, let placemark = placemarks?.first, let location = placemark.location else {
                geocodeError = "Couldn't find that location. Try a full street address."
                return
            }

            coordinate = location.coordinate

            var parts: [String] = []
            if let number = placemark.subThoroughfare { parts.append(number) }
            if let street = placemark.thoroughfare { parts.append(street) }
            if let city = placemark.locality { parts.append(city) }
            if let state = placemark.administrativeArea { parts.append(state) }
            resolvedAddress = parts.joined(separator: " ")
        }
    }

    private func addSpot() {
        guard let coord = coordinate else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let finalAddress = resolvedAddress.isEmpty
            ? address.trimmingCharacters(in: .whitespaces)
            : resolvedAddress

        let spot = StudySpot(
            name: trimmedName,
            address: finalAddress,
            latitude: coord.latitude,
            longitude: coord.longitude
        )
        spot.isUserAdded = true
        modelContext.insert(spot)
        try? modelContext.save()
        dismiss()
    }
}
