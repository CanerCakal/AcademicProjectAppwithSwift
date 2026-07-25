import Foundation
import Combine

@MainActor
class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var errorMessage: String?

    private let service: CommentServiceProtocol

    init(service: CommentServiceProtocol = FirestoreCommentService()) {
        self.service = service
    }

    func fetchComments(projectId: String) async {
        do {
            self.comments = try await service.fetchComments(projectId: projectId)
        } catch {
            self.errorMessage = "Yorumlar yüklenirken hata oluştu: \(error.localizedDescription)"
        }
    }

    func addComment(projectId: String, text: String, authorId: String, authorName: String) async {
        let newComment = Comment(
            text: text,
            authorId: authorId,
            authorName: authorName,
            createdAt: Date()
        )
        do {
            try await service.addComment(projectId: projectId, comment: newComment)
            await fetchComments(projectId: projectId)
        } catch {
            self.errorMessage = "Yorum eklenirken hata oluştu: \(error.localizedDescription)"
        }
    }
}
