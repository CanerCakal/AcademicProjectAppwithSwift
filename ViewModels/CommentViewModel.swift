import Foundation
import Combine

@MainActor
class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var errorMessage: String?

    private let service: CommentServiceProtocol
    private var listenerTask: Task<Void, Never>?

    init(service: CommentServiceProtocol = FirestoreCommentService()) {
        self.service = service
    }

    func startListening(projectId: String) {
        listenerTask?.cancel()
        listenerTask = Task {
            for await updatedComments in service.commentsStream(projectId: projectId) {
                self.comments = updatedComments
            }
        }
    }

    func stopListening() {
        listenerTask?.cancel()
        listenerTask = nil
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
        } catch {
            self.errorMessage = "Yorum eklenirken hata oluştu: \(error.localizedDescription)"
        }
    }

    deinit {
        listenerTask?.cancel()
    }
}
