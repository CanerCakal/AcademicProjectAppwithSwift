//
//  Course.swift
//  AcademicProject
//
//  Created by Caner Çakal on 19.03.2026.
//

import Foundation
import FirebaseFirestore

struct Course: Identifiable, Codable {
    @DocumentID var id: String?
    var courseCode: String
    var courseName: String
    var term: String
    var departmentId: String?
    var instructorId: String?
}
