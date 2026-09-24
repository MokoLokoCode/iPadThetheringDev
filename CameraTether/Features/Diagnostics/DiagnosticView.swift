import SwiftUI

/// Brand-neutral presentation; no ImageCaptureCore objects enter this view.
struct DiagnosticView: View {
    let status: String
    let events: [CameraDiagnosticEvent]
    let exportText: String
    let start: () -> Void
    let stop: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(status).font(.headline)
                Text("Discovery only. File events and downloads will be added after the physical USB test.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("Start", action: start)
                    Button("Stop", action: stop)
                    ShareLink(item: exportText) {
                        Label("Share log", systemImage: "square.and.arrow.up")
                    }
                    .disabled(events.isEmpty)
                }
                .buttonStyle(.bordered)

                List(events.reversed()) { event in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(event.time.formatted(date: .numeric, time: .standard))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                        Text(event.message)
                            .font(.callout.monospaced())
                            .textSelection(.enabled)
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("Camera diagnostics")
        }
    }
}
