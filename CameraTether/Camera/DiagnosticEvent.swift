import Foundation

/// Brand-neutral diagnostic record shared by camera adapters and the iPad view.
struct CameraDiagnosticEvent: Identifiable {
    let id = UUID()
    let time = Date()
    let message: String
}
