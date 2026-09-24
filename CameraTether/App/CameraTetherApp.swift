import SwiftUI

@main
struct CameraTetherApp: App {
    #if os(macOS)
    @State private var store = CullStore(
        sessionsRoot: PlatformShell.sessionsRoot,
        defaultOutboxRoot: PlatformShell.defaultOutboxRoot
    )
    #else
    @StateObject private var fujifilmDiscovery = FujifilmDiscovery()
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
        // The iPad uses the observational Fujifilm discovery probe.
        WindowGroup {
            DiagnosticView(
                status: fujifilmDiscovery.status,
                events: fujifilmDiscovery.events,
                exportText: fujifilmDiscovery.exportText,
                start: { fujifilmDiscovery.start() },
                stop: { fujifilmDiscovery.stop() }
            )
            .onAppear { fujifilmDiscovery.start() }
            .onDisappear { fujifilmDiscovery.stop() }
        }
        #endif
    }
}
