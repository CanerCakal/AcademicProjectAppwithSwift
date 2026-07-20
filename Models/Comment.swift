import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var authorId: String
    var authorName: String
    var createdAt: Date
}
