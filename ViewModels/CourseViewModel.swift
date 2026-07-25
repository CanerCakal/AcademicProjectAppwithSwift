import Foundation
import Combine

@MainActor
class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var errorMessage: String?

    private let service: CourseServiceProtocol

    init(service: CourseServiceProtocol = FirestoreCourseService()) {
        self.service = service
    }

    func fetchCourses() async {
        do {
            self.courses = try await service.fetchCourses()
        } catch {
            print("Dersler yüklenirken hata oluştu: \(error.localizedDescription)")
        }
    }

    func addCourse(courseCode: String, courseName: String, term: String, instructorId: String?) async {
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
            instructorId: instructorId
        )

        do {
            try await service.addCourse(newCourse)
            await fetchCourses()
        } catch {
            self.errorMessage = "Ders eklenirken hata oluştu: \(error.localizedDescription)"
        }
    }

    func assignInstructor(courseId: String, instructorId: String?) async {
        do {
            try await service.assignInstructor(courseId: courseId, instructorId: instructorId)
            await fetchCourses()
        } catch {
            self.errorMessage = "Akademisyen atanırken hata oluştu: \(error.localizedDescription)"
        }
    }
}
