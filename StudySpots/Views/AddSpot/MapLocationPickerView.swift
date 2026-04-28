import SwiftUI
import MapKit
internal import CoreLocation

struct MapLocationPickerView: View {

    @Binding var coordinate: CLLocationCoordinate2D?
    @Binding var resolvedAddress: String
    @Environment(\.dismiss) private var dismiss

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9522, longitude: -75.1932),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: 39.9522, longitude: -75.1932)
    @State private var isConfirming = false

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition)
                    .onMapCameraChange { context in
                        centerCoordinate = context.region.center
                    }
                    .ignoresSafeArea()

                // Fixed crosshair pin — always at screen center
                VStack(spacing: 0) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)

                    Ellipse()
                        .fill(.black.opacity(0.15))
                        .frame(width: 14, height: 5)
                        .blur(radius: 2)
                }
                // Nudge up so pin tip sits at center, not the icon center
                .offset(y: -24)

                // Hint label
                VStack {
                    Spacer()
                    Label("Drag the map to move the pin", systemImage: "hand.draw")
                        .font(.caption)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.regularMaterial)
                        .clipShape(Capsule())
                        .padding(.bottom, 110)
                }
            }
            .navigationTitle("Pick Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: confirmLocation) {
                    Group {
                        if isConfirming {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Confirm Location")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                }
                .disabled(isConfirming)
                .background(.regularMaterial)
            }
        }
    }

    private func confirmLocation() {
        isConfirming = true
        let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            isConfirming = false
            coordinate = centerCoordinate

            if let placemark = placemarks?.first {
                var parts: [String] = []
                if let number = placemark.subThoroughfare { parts.append(number) }
                if let street = placemark.thoroughfare { parts.append(street) }
                if let city = placemark.locality { parts.append(city) }
                if let state = placemark.administrativeArea { parts.append(state) }
                resolvedAddress = parts.joined(separator: " ")
            }

            dismiss()
        }
    }
}
