import SwiftUI

/// The launch baseline, before adding a camera transport or diagnostic events.
struct DiagnosticView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Label("Setup build", systemImage: "ipad")
                        .font(.title2.bold())

                    Text("CameraTether is running")
                        .font(.title.bold())
                        .accessibilityAddTraits(.isHeader)

                    Text("This first build checks that the app launches on your iPad.")

                    Divider()

                    Label("Camera connection is not implemented yet", systemImage: "camera")
                        .font(.headline)

                    Text("After the launch test, we’ll add camera discovery and capture-event logging.")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 640, alignment: .leading)
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("CameraTether")
        }
    }
}
