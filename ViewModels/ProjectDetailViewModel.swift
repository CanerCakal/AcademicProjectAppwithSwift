import Foundation
import FirebaseFirestore
import Combine

@MainActor
class ProjectDetailViewModel: ObservableObject {
    
    @Published var course: Course?
    @Published var student: User?
    @Published var isLoading = true
    
    private var db = Firestore.firestore()
    
    func fetchRelatedData(courseId: String, studentId: String) async {
        do {
            let courseDoc = try await db.collection("courses").document(courseId).getDocument()
            self.course = try? courseDoc.data(as: Course.self)
            
            let userDoc = try await db.collection("users").document(studentId).getDocument()
            self.student = try? userDoc.data(as: User.self)
            
        } catch {
            print("Veriler birleştirilirken hata oluştu: \(error.localizedDescription)")
        }
        
        self.isLoading = false
    }
}
