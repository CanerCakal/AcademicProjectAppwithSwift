//
//  Department.swift
//  AcademicProject
//
//  Created by Caner Çakal on 19.03.2026.
//

import Foundation
import FirebaseFirestore

struct Department: Identifiable, Codable {
    @DocumentID var id: String?
    var departmentName: String
}
