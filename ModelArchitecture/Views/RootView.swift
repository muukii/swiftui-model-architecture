import SwiftUI

struct RootView: View {
  @Bindable var model: AppModel

  var body: some View {
    TabView(selection: $model.selectedTab) {
      SheetsTabView(model: model.sheetsTabModel)
        .tabItem {
          Label("Sheets", systemImage: "square.stack")
        }
        .tag(AppModel.Tab.sheets)

      NavigationTabView(model: model.navigationTabModel)
        .tabItem {
          Label("Navigation", systemImage: "arrow.right.square")
        }
        .tag(AppModel.Tab.navigation)

      AsyncTabView(model: model.asyncTabModel)
        .tabItem {
          Label("Async", systemImage: "arrow.triangle.2.circlepath")
        }
        .tag(AppModel.Tab.async)

      SettingsTabView(model: model.settingsTabModel)
        .tabItem {
          Label("Settings", systemImage: "gearshape")
        }
        .tag(AppModel.Tab.settings)
    }
  }
}

#Preview {
  RootView(model: AppModel())
}
