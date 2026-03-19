//
//  User.swift
//  AcademicProject
//
//  Created by Caner Çakal on 19.03.2026.
//

import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var fullName: String
    var email: String
    var roleId: Int
    var departmentId: String?
}
