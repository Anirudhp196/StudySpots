import SwiftUI
import SwiftData
import MapKit
internal import CoreLocation

struct SpotMapView: View {

    @Query private var spots: [StudySpot]
    @Environment(LocationViewModel.self) private var locationVM
    @Environment(\.modelContext) private var modelContext

    @State private var selectedSpot: StudySpot?
    @State private var showDetail = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9522, longitude: -75.1932),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                UserAnnotation()

                ForEach(spots) { spot in
                    Annotation(spot.name, coordinate: spot.coordinate) {
                        SpotPinView(
                            spot: spot,
                            isSelected: selectedSpot?.id == spot.id
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedSpot = spot
                                cameraPosition = .region(MKCoordinateRegion(
                                    center: spot.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                                ))
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                if let spot = selectedSpot {
                    spotPreviewCard(spot)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationDestination(isPresented: $showDetail) {
                if let spot = selectedSpot {
                    SpotDetailView(spot: spot)
                }
            }
            .onAppear {
                if let location = locationVM.userLocation {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                }
            }
        }
    }

    private func spotPreviewCard(_ spot: StudySpot) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text(spot.averageRating > 0
                         ? String(format: "%.1f", spot.averageRating)
                         : "No ratings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let dist = locationVM.formattedDistance(to: spot) {
                        Text("· \(dist)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button {
                spot.isBookmarked.toggle()
                try? modelContext.save()
            } label: {
                Image(systemName: spot.isBookmarked ? "bookmark.fill" : "bookmark")
                    .symbolEffect(.bounce, value: spot.isBookmarked)
                    .foregroundStyle(spot.isBookmarked ? .blue : .secondary)
                    .font(.title3)
            }

            Button {
                showDetail = true
            } label: {
                Text("View")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }

            Button {
                withAnimation {
                    selectedSpot = nil
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .font(.title3)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -2)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct SpotPinView: View {

    let spot: StudySpot
    let isSelected: Bool

    private var pinColor: Color {
        spot.isUserAdded ? .green : .blue
    }

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(isSelected ? pinColor : .white)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                Image(systemName: spot.isUserAdded ? "plus.circle.fill" : "book.fill")
                    .foregroundStyle(isSelected ? .white : pinColor)
                    .font(isSelected ? .body : .subheadline)
            }

            if isSelected {
                Text(spot.name)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
                    .lineLimit(1)
            }
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
    SpotMapView()
        .environment(LocationViewModel())
        .modelContainer(for: [StudySpot.self, Review.self], inMemory: true)
}
