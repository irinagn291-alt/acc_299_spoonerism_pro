import SwiftUI
import UIKit

/// A locally bundled painting takes priority over the network.
struct QuizTile: View {
    let work: Work?
    let showSuccess: Bool
    @State private var photo: UIImage?
    @State private var loading = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MarrowInk.ink
                if let bundled = work.flatMap({ UIImage(named: "painting_" + $0.objectID) }) {
                    picture(bundled, size: geometry.size)
                } else if let photo {
                    picture(photo, size: geometry.size)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.artframe").font(.system(size: 36, weight: .ultraLight))
                        Text(loading ? "Opening the artwork…" : "Artwork unavailable offline")
                            .font(.caption)
                    }
                    .foregroundStyle(MarrowInk.surface.opacity(0.8))
                }
                if showSuccess {
                    VStack {
                        HStack {
                            Spacer()
                            Label("Solved", systemImage: "checkmark.circle.fill")
                                .font(.caption.weight(.semibold))
                                .padding(12)
                                .background(MarrowInk.surface, in: Capsule())
                                .foregroundStyle(MarrowInk.accent)
                        }
                        Spacer()
                    }
                    .padding(16)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipped()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(work.map { "\($0.title), \($0.artist)" } ?? "Painting")
        .task(id: work?.imageURL) { await loadPhoto() }
    }

    private func picture(_ image: UIImage, size: CGSize) -> some View {
        Image(uiImage: image).resizable().scaledToFit().frame(width: size.width, height: size.height)
    }

    private func loadPhoto() async {
        photo = nil
        guard let work, UIImage(named: "painting_" + work.objectID) == nil,
              let url = work.imageURL else { return }
        loading = true
        defer { loading = false }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard !Task.isCancelled, let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode) else { return }
            photo = UIImage(data: data)
        } catch { photo = nil }
    }
}
