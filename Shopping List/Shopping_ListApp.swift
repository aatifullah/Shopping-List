//
//  Shopping_ListApp.swift
//  Shopping List
//
//  Created by Aatif Ullah on 2/28/26.
//

import SwiftUI
import SwiftData

@main
struct Shopping_ListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: GroceryItem.self)
    }
}
