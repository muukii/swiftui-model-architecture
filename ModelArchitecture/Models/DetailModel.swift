import Foundation

@Observable
class DetailModel: Identifiable {
  let id: UUID
  let item: Item

  init(item: Item) {
    self.id = UUID()
    self.item = item
  }
}
