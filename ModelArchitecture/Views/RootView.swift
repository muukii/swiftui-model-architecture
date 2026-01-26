import SwiftUI

struct RootView: View {
  let model: AppModel

  var body: some View {
    HomeView(model: model.homeModel)
  }
}

#Preview {
  RootView(model: AppModel())
}
