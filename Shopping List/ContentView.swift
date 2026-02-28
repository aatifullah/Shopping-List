//
//  ContentView.swift
//  Shopping List
//
//  Created by Aatif Ullah on 2/28/26.
//
import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var context
    @Query(sort: \GroceryItem.createdAt) private var items: [GroceryItem]

    @State private var viewModel = GroceryListViewModel()

    @State private var name: String = ""
    @State private var category: Category = .milk
    @State private var editingItem: GroceryItem?
    @State private var selectedFilter: Category? = nil

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: Filtering
    private var filteredItems: [GroceryItem] {
        if let selectedFilter {
            return items.filter { $0.category == selectedFilter }
        }
        return items
    }

    // MARK: Grouping
    private var groupedItems: [(Category, [GroceryItem])] {
        let grouped = Dictionary(grouping: filteredItems) { $0.category }

        return Category.allCases.compactMap { category in
            guard let items = grouped[category] else { return nil }
            return (
                category,
                items.sorted {
                    ($0.isCompleted ? 1 : 0) < ($1.isCompleted ? 1 : 0)
                }
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // MARK: Header
                    VStack(spacing: 14) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 90, height: 90)
                            .overlay(
                                Image(systemName: "cart.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 34))
                            )

                        Text("Grocery List")
                            .font(.title.bold())

                        Text("Add items to your shopping list")
                            .foregroundStyle(.secondary)
                    }

                    // MARK: Add Card
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Add New Item")
                            .font(.title3.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 18)
                            .padding(.horizontal, 20)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.95),
                                        Color.blue.opacity(0.95)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .shadow(
                                color: .purple.opacity(0.25),
                                radius: 12,
                                x: 0,
                                y: 6
                            )

                        // Item Name Label
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Item Name")
                                .font(.subheadline.weight(.semibold))

                            TextField("Enter grocery item...", text: $name)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // Category Selection
                        HStack(spacing: 12) {
                            ForEach(Category.allCases) { cat in
                                CategoryButton(
                                    category: cat,
                                    isSelected: category == cat
                                ) {
                                    category = cat
                                }
                            }
                        }

                        // Add Item Button
                        Button {
                            withAnimation {
                                viewModel.addItem(
                                    name: name,
                                    category: category,
                                    context: context
                                )
                                name = ""
                                hideKeyboard()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Item")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                isValid
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                : AnyShapeStyle(Color(.systemGray))
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(!isValid)

                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .shadow(color: .black.opacity(0.05), radius: 10)

                    // MARK: Filter Chips (Only when items exist)
                    if !items.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {

                                FilterChip(
                                    title: "All",
                                    isSelected: selectedFilter == nil
                                ) {
                                    selectedFilter = nil
                                }

                                ForEach(Category.allCases) { cat in
                                    FilterChip(
                                        title: cat.rawValue,
                                        isSelected: selectedFilter == cat
                                    ) {
                                        selectedFilter = cat
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // MARK: Items Section
                    if filteredItems.isEmpty {

                        VStack(spacing: 14) {
                            Image(systemName: "cart")
                                .font(.system(size: 50))
                                .foregroundStyle(.gray.opacity(0.6))

                            Text("Your grocery list is empty")
                                .font(.headline)

                            Text("Add items above to get started")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 40)

                    } else {

                        VStack(alignment: .leading, spacing: 20) {

                            ForEach(groupedItems, id: \.0) { category, items in

                                VStack(alignment: .leading, spacing: 12) {

                                    Text(category.rawValue)
                                        .font(.title3.bold())
                                        .padding(.horizontal)

                                    ForEach(items) { item in
                                        ModernCardRow(
                                            item: item,
                                            onToggle: {
                                                withAnimation {
                                                    viewModel.toggleCompletion(item, context: context)
                                                }
                                            },
                                            onDelete: {
                                                withAnimation {
                                                    viewModel.deleteItem(item, context: context)
                                                }
                                            },
                                            onEdit: {
                                                editingItem = item
                                            }
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
            .sheet(item: $editingItem) { item in
                EditView(
                    item: item,
                    onSave: { newName, newCategory in
                        viewModel.updateItem(
                            item,
                            name: newName,
                            category: newCategory,
                            context: context
                        )
                    }
                )
            }
        }
    }
}

// MARK: Keyboard Dismiss
private func hideKeyboard() {
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder),
        to: nil,
        from: nil,
        for: nil
    )
}
struct FilterChip: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(
                    isSelected
                    ? Color.blue
                    : Color(.systemGray6)
                )
                .foregroundColor(
                    isSelected ? .white : .primary
                )
                .clipShape(Capsule())
        }
    }
}

struct EditView: View {
    @Environment(\.dismiss) private var dismiss
    
    let item: GroceryItem
    let onSave: (String, Category) -> Void
    
    @State private var name: String
    @State private var category: Category
    
    init(item: GroceryItem,
         onSave: @escaping (String, Category) -> Void) {
        self.item = item
        self.onSave = onSave
        _name = State(initialValue: item.name)
        _category = State(initialValue: item.category)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Item name", text: $name)
                
                Picker("Category", selection: $category) {
                    ForEach(Category.allCases) {
                        Text($0.rawValue).tag($0)
                    }
                }
            }
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, category)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(categoryIcon)
                    .font(.system(size: 20))
                
                Text(category.rawValue)
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .background(
                isSelected ?
                Color.blue :
                    Color(.systemGray6)
            )
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
    
    var categoryIcon: String {
        switch category {
        case .milk: return "🥛"
        case .vegetables: return "🥕"
        case .fruits: return "🍎"
        case .breads: return "🍞"
        case .meats: return "🥩"
        }
    }
}

struct ModernRow: View {
    let item: GroceryItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName:
                        item.isCompleted ?
                      "checkmark.circle.fill" :
                        "circle")
                .foregroundColor(item.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .strikethrough(item.isCompleted)
                    .font(.headline)
                
                Text(item.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("Your grocery list is empty")
                .font(.headline)
            
            Text("Add items above to get started")
                .foregroundColor(.secondary)
        }
        .padding(.top, 40)
    }
}

struct ModernCardRow: View {

    let item: GroceryItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 14) {

            // Completion Button
            Button(action: onToggle) {
                Image(systemName:
                        item.isCompleted
                        ? "checkmark.circle.fill"
                        : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        item.isCompleted
                        ? .green
                        : .gray.opacity(0.6)
                    )
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {

                Text(item.name)
                    .font(.headline)
                    .strikethrough(item.isCompleted)
                    .foregroundStyle(
                        item.isCompleted
                        ? .secondary
                        : .primary
                    )

                Text(item.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }

            Spacer()
            
            Menu {
                Button("Edit", action: onEdit)
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundStyle(.gray)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05),
                        radius: 8,
                        x: 0,
                        y: 4)
        )
    }
}

#Preview {
    ContentView()
}
