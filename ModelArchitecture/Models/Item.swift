import Foundation

struct Item: Identifiable, Hashable {
  let id: UUID
  let name: String

  init(id: UUID = UUID(), name: String) {
    self.id = id
    self.name = name
  }
}
