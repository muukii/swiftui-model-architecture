import Foundation

/// Demonstrates Sheet Navigation and Confirmation Dialog patterns.
///
/// - Sheet Navigation: `detailModel` property controls sheet presentation
/// - Confirmation Dialog: `deleteConfirmation` property controls dialog presentation
@Observable
class SheetsTabModel {
  var items: [Item] = [
    Item(name: "Item 1"),
    Item(name: "Item 2"),
    Item(name: "Item 3"),
  ]

  /// When non-nil, a detail sheet should be presented.
  var detailModel: DetailModel?

  /// When non-nil, a confirmation dialog should be shown.
  var deleteConfirmation: Item?

  // MARK: - Sheet Navigation

  func showDetail(item: Item) {
    detailModel = DetailModel(item: item)
  }

  func dismissDetail() {
    detailModel = nil
  }

  // MARK: - Add Item

  func addItem() {
    let newItem = Item(name: "Item \(items.count + 1)")
    items.append(newItem)
  }

  // MARK: - Delete Actions

  /// Request deletion of an item. Shows confirmation dialog.
  func requestDelete(_ item: Item) {
    deleteConfirmation = item
  }

  /// Execute the pending deletion.
  func executeDelete() {
    guard let item = deleteConfirmation else { return }
    items.removeAll { $0.id == item.id }
    deleteConfirmation = nil
  }

  /// Cancel the pending deletion.
  func cancelDelete() {
    deleteConfirmation = nil
  }
}
