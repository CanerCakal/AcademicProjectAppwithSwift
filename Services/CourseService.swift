import Foundation
import FirebaseFirestore

protocol CourseServiceProtocol {
    func fetchCourses() async throws -> [Course]
    func addCourse(_ course: Course) async throws
    func assignInstructor(courseId: String, instructorId: String?) async throws
}

final class FirestoreCourseService: CourseServiceProtocol {
    private let db = Firestore.firestore()
    private let collectionName = "courses"

    func fetchCourses() async throws -> [Course] {
        let snapshot = try await db.collection(collectionName).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Course.self) }
    }

    func addCourse(_ course: Course) async throws {
        try db.collection(collectionName).addDocument(from: course)
    }

    func assignInstructor(courseId: String, instructorId: String?) async throws {
        try await db.collection(collectionName).document(courseId).updateData([
            "instructorId": instructorId as Any
        ])
    }
}
