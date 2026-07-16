import Foundation

enum RoleResolver {
    static let adminRole = 1
    static let teacherRole = 2
    static let studentRole = 3

    private static let studentDomains = ["ogr.dpu.edu.tr"]
    private static let teacherDomains = ["dpu.edu.tr"]

    static func role(for email: String) -> Int {
        let normalized = email.lowercased().trimmingCharacters(in: .whitespaces)

        guard let domain = normalized.split(separator: "@").last.map(String.init) else {
            return studentRole
        }

        if studentDomains.contains(domain) {
            return studentRole
        }

        if teacherDomains.contains(domain) {
            return teacherRole
        }

        return studentRole
    }

    static func isValidInstitutionalEmail(_ email: String) -> Bool {
        let normalized = email.lowercased().trimmingCharacters(in: .whitespaces)
        guard let domain = normalized.split(separator: "@").last.map(String.init) else {
            return false
        }
        return studentDomains.contains(domain) || teacherDomains.contains(domain)
    }
    
    static func roleName(for roleId: Int) -> String {
            switch roleId {
            case adminRole: return "Yönetici"
            case teacherRole: return "Akademisyen"
            default: return "Öğrenci"
            }
        }
}
