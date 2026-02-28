//
//  GroceryListViewModel.swift
//  Shopping List
//
//  Created by Aatif Ullah on 2/28/26.
//
import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class GroceryListViewModel {

    var selectedCategory: Category? = nil

    func addItem(name: String, category: Category, context: ModelContext) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        context.insert(GroceryItem(name: trimmed, category: category))
        try? context.save()
    }

    func deleteItem(_ item: GroceryItem, context: ModelContext) {
        context.delete(item)
        try? context.save()
    }

    func toggleCompletion(_ item: GroceryItem, context: ModelContext) {
        item.isCompleted.toggle()
        try? context.save()
    }

    func updateItem(_ item: GroceryItem,
                    name: String,
                    category: Category,
                    context: ModelContext) {

        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        item.name = trimmed
        item.category = category
        try? context.save()
    }
}
