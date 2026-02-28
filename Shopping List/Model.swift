//
//  Model.swift
//  Shopping List
//
//  Created by Aatif Ullah on 2/28/26.
//
import Foundation
import SwiftData

enum Category: String, CaseIterable, Identifiable, Codable {
    case milk = "Milk"
    case vegetables = "Vegetables"
    case fruits = "Fruits"
    case breads = "Breads"
    case meats = "Meats"

    var id: String { rawValue }
}

@Model
final class GroceryItem {
    var id: UUID
    var name: String
    var categoryRaw: String
    var isCompleted: Bool
    var createdAt: Date

    var category: Category {
        get { Category(rawValue: categoryRaw) ?? .milk }
        set { categoryRaw = newValue.rawValue }
    }

    init(name: String, category: Category) {
        self.id = UUID()
        self.name = name
        self.categoryRaw = category.rawValue
        self.isCompleted = false
        self.createdAt = Date()
    }
}
