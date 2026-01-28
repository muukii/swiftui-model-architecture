import Foundation

/// Demonstrates NavigationStack (path-based) and Model-per-Screen patterns.
///
/// - Path-based Navigation: `path` array controls the navigation stack
/// - Model-per-Screen: Each detail screen has its own Model, cached for performance
@Observable
class NavigationTabModel {
  enum Destination: Hashable {
    case itemDetail(Item)
    case settings
    case about
  }

  var items: [Item] = [
    Item(name: "Navigation Item 1"),
    Item(name: "Navigation Item 2"),
    Item(name: "Navigation Item 3"),
  ]

  /// Navigation stack path. Changes to this array update the navigation.
  var path: [Destination] = []

  // MARK: - Model-per-Screen Cache

  /// Cached Models for item detail screens.
  /// Models are created on-demand and cleaned up when no longer in path.
  private var itemDetailModels: [Item.ID: ItemDetailModel] = [:]

  // MARK: - Navigation Actions

  func push(_ destination: Destination) {
    path.append(destination)
  }

  func pop() {
    guard !path.isEmpty else { return }
    path.removeLast()
    cleanupUnusedModels()
  }

  func popToRoot() {
    path.removeAll()
    cleanupUnusedModels()
  }

  // MARK: - Model-per-Screen

  /// Get or create a Model for the item detail screen.
  /// Models are cached to preserve state during navigation.
  func itemDetailModel(for item: Item) -> ItemDetailModel {
    if let existing = itemDetailModels[item.id] {
      return existing
    }
    let newModel = ItemDetailModel(item: item)
    itemDetailModels[item.id] = newModel
    return newModel
  }

  /// Remove Models that are no longer referenced in the navigation path.
  private func cleanupUnusedModels() {
    let activeItemIDs = Set(path.compactMap { destination -> Item.ID? in
      if case .itemDetail(let item) = destination {
        return item.id
      }
      return nil
    })

    itemDetailModels = itemDetailModels.filter { activeItemIDs.contains($0.key) }
  }
}

// MARK: - Item Detail Model

/// Model for the item detail screen in navigation.
/// Demonstrates Model-per-Screen pattern with its own state.
@Observable
class ItemDetailModel {
  let item: Item
  var notes: String = ""
  var isFavorite: Bool = false

  init(item: Item) {
    self.item = item
  }

  func toggleFavorite() {
    isFavorite.toggle()
  }
}
