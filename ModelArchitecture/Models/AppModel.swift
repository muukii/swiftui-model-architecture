import Foundation

@Observable
class AppModel {
  var homeModel: HomeModel

  init() {
    homeModel = HomeModel()
  }
}
