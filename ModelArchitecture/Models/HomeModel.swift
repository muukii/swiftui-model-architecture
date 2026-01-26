import Foundation

@Observable
class HomeModel {
  var items: [Item] = [
    Item(name: "Item 1"),
    Item(name: "Item 2"),
    Item(name: "Item 3"),
  ]

  var detailModel: DetailModel?

  func showDetail(item: Item) {
    detailModel = DetailModel(item: item)
  }

  func dismissDetail() {
    detailModel = nil
  }
}
