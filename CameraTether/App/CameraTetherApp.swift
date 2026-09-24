import SwiftUI

@main
struct CameraTetherApp: App {
    #if os(macOS)
    @State private var store = CullStore(
        sessionsRoot: PlatformShell.sessionsRoot,
        defaultOutboxRoot: PlatformShell.defaultOutboxRoot
    )
    #endif

    var body: some Scene {
        #if os(macOS)
        // The Mac runs the event culling flow (D-014, D-015).
        Window("CameraTether", id: "cull") {
            CullView(store: store)
                .frame(minWidth: 900, minHeight: 600)
                .onAppear { store.start() }
        }
        #else
        // The iPad keeps the launch baseline until its camera path is validated.
        WindowGroup {
            DiagnosticView()
        }
        #endif
    }
}
