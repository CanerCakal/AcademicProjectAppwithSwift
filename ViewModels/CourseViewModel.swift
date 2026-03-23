import Foundation
import FirebaseFirestore
import Combine

@MainActor
class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    
    private var db = Firestore.firestore()
    
    func fetchCourses() async {
        do {
            let snapshot = try await db.collection("courses").getDocuments()
            self.courses = snapshot.documents.compactMap { try? $0.data(as: Course.self) }
        } catch {
            print("Dersler yüklenirken hata oluştu: \(error.localizedDescription)")
        }
    }
}
