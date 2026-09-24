import SwiftUI

/// Every shot in capture order; the selection stays scrolled into view.
struct FilmstripView: View {
    let store: CullStore

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 6) {
                    ForEach(store.shots) { shot in
                        Thumbnail(url: store.url(for: shot), shot: shot, isSelected: shot.id == store.selectedID)
                            .id(shot.id)
                            .onTapGesture { store.select(shot.id) }
                    }
                }
                .padding(8)
            }
            .frame(height: 112)
            .onChange(of: store.selectedID) { _, id in
                guard let id else { return }
                withAnimation(.easeOut(duration: 0.15)) { proxy.scrollTo(id, anchor: .center) }
            }
        }
        .background(.black)
    }
}

private struct Thumbnail: View {
    let url: URL
    let shot: Shot
    let isSelected: Bool
    @State private var image: CGImage?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let image {
                    Image(decorative: image, scale: 1).resizable().scaledToFit()
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 128, height: 96)
            .opacity(shot.isRejected ? 0.3 : 1)

            Image(systemName: symbol)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(4)
                .background(color, in: .circle)
                .padding(4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 3)
        }
        .task(id: url) {
            image = await ImageLoader.shared.image(for: url, maxPixelSize: 256)
        }
    }

    private var symbol: String {
        switch shot.state {
        case .pending: "timer"
        case .published: "checkmark"
        case .rejected: "xmark"
        }
    }

    private var color: Color {
        switch shot.state {
        case .pending: .orange
        case .published: .green
        case .rejected: .red
        }
    }
}
