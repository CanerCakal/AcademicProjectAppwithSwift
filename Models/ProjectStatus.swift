import SwiftUI

enum ProjectStatus: String, Codable, CaseIterable {
    case proposal
    case development
    case approved
    case rejected

    var label: String {
        switch self {
        case .proposal: return "Öneri"
        case .development: return "Geliştirme"
        case .approved: return "Onaylandı"
        case .rejected: return "Reddedildi"
        }
    }

    var color: Color {
        switch self {
        case .proposal: return .statusProposal
        case .development: return .statusDevelopment
        case .approved: return .statusApproved
        case .rejected: return .statusRejected
        }
    }
}
