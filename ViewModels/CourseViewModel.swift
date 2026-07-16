import Foundation
import FirebaseFirestore
import Combine

@MainActor
class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    func fetchCourses() async {
        do {
            let snapshot = try await db.collection("courses").getDocuments()
            self.courses = snapshot.documents.compactMap { try? $0.data(as: Course.self) }
        } catch {
            print("Dersler yüklenirken hata oluştu: \(error.localizedDescription)")
        }
    }
    
    func addCourse(courseCode: String, courseName: String, term: String) async {
        let trimmedCode = courseCode.trimmingCharacters(in: .whitespaces).uppercased()
        
        let exists = courses.contains {
            $0.courseCode.trimmingCharacters(in: .whitespaces).uppercased() == trimmedCode
        }
        
        if exists {
            self.errorMessage = "Bu ders kodu (\(trimmedCode)) zaten mevcut."
            return
        }
        
        let newCourse = Course(
            courseCode: trimmedCode,
            courseName: courseName,
            term: term,
            departmentId: nil,
            ınstructorId: nil
        )
        do {
            try db.collection("courses").addDocument(from: newCourse)
            await fetchCourses()
        } catch {
            self.errorMessage = "Ders eklenirken hata oluştu: \(error.localizedDescription)"
        }
    }
}
