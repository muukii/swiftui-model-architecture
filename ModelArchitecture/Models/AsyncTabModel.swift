import Foundation

/// Demonstrates Async Operations, Loading State, and Error Alert patterns.
///
/// - Loading State: `isLoading` property tracks async operation progress
/// - Error Alert: `errorAlert` property controls error alert presentation
@Observable
class AsyncTabModel {
  var items: [Item] = []
  var isLoading = false
  var errorAlert: ErrorInfo?

  // MARK: - Error Info

  struct ErrorInfo: Identifiable {
    let id = UUID()
    let title: String
    let message: String
  }

  // MARK: - Async Actions

  /// Load items asynchronously. Simulates network request with random success/failure.
  @MainActor
  func loadItems() async {
    guard !isLoading else { return }

    isLoading = true
    defer { isLoading = false }

    // Simulate network delay
    try? await Task.sleep(for: .seconds(1.5))

    // Simulate random success/failure (70% success rate)
    if Double.random(in: 0...1) > 0.3 {
      items = [
        Item(name: "Loaded Item 1"),
        Item(name: "Loaded Item 2"),
        Item(name: "Loaded Item 3"),
        Item(name: "Loaded Item 4"),
      ]
    } else {
      errorAlert = ErrorInfo(
        title: "Load Failed",
        message: "Unable to load items. Please try again."
      )
    }
  }

  /// Refresh items. Clears existing items and reloads.
  @MainActor
  func refresh() async {
    items = []
    await loadItems()
  }

  /// Simulate adding an item with async operation.
  @MainActor
  func addItem() async {
    guard !isLoading else { return }

    isLoading = true
    defer { isLoading = false }

    // Simulate network delay
    try? await Task.sleep(for: .seconds(0.5))

    let newItem = Item(name: "New Item \(items.count + 1)")
    items.append(newItem)
  }

  /// Delete an item with async operation.
  @MainActor
  func deleteItem(_ item: Item) async {
    guard !isLoading else { return }

    isLoading = true
    defer { isLoading = false }

    // Simulate network delay
    try? await Task.sleep(for: .seconds(0.3))

    // Simulate random failure (20% failure rate)
    if Double.random(in: 0...1) > 0.2 {
      items.removeAll { $0.id == item.id }
    } else {
      errorAlert = ErrorInfo(
        title: "Delete Failed",
        message: "Unable to delete \(item.name). Please try again."
      )
    }
  }

  // MARK: - Error Handling

  func dismissError() {
    errorAlert = nil
  }
}
