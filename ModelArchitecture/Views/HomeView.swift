import SwiftUI

struct HomeView: View {
  @Bindable var model: HomeModel

  var body: some View {
    NavigationStack {
      List(model.items) { item in
        Button(item.name) {
          model.showDetail(item: item)
        }
      }
      .navigationTitle("Home")
    }
    .sheet(item: $model.detailModel) { detail in
      DetailView(model: detail)
    }
  }
}

#Preview {
  HomeView(model: HomeModel())
}
