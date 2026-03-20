//
//  Project.swift
//  AcademicProject
//
//  Created by Caner Çakal on 19.03.2026.
//

import Foundation
import FirebaseFirestore

struct Project: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var summary: String?
    var status: String
    var courseId: String
    var createdBy: String
}
