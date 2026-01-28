import SwiftUI

/// Demonstrates NavigationStack (path-based) and Model-per-Screen patterns.
///
/// Patterns demonstrated:
/// - Path-based Navigation: `model.path` controls the navigation stack
/// - Model-per-Screen: Each detail screen has its own Model via `model.itemDetailModel(for:)`
struct NavigationTabView: View {
  @Bindable var model: NavigationTabModel

  var body: some View {
    NavigationStack(path: $model.path) {
      List(model.items) { item in
        Button {
          model.push(.itemDetail(item))
        } label: {
          HStack {
            Text(item.name)
            Spacer()
            Image(systemName: "chevron.right")
              .foregroundStyle(.secondary)
          }
        }
        .foregroundStyle(.primary)
      }
      .navigationTitle("Navigation")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            model.push(.settings)
          } label: {
            Image(systemName: "gearshape")
          }
        }
      }
      .navigationDestination(for: NavigationTabModel.Destination.self) { destination in
        destinationView(for: destination)
      }
    }
  }

  @ViewBuilder
  private func destinationView(for destination: NavigationTabModel.Destination) -> some View {
    switch destination {
    case .itemDetail(let item):
      ItemDetailNavigationView(
        model: model.itemDetailModel(for: item),
        onNavigateToSettings: { model.push(.settings) },
        onNavigateToAbout: { model.push(.about) }
      )
    case .settings:
      NavigationSettingsView(onPopToRoot: { model.popToRoot() })
    case .about:
      NavigationAboutView()
    }
  }
}

// MARK: - Item Detail View

/// Detail view demonstrating Model-per-Screen pattern.
/// This view has its own Model that persists while navigating deeper.
struct ItemDetailNavigationView: View {
  @Bindable var model: ItemDetailModel
  let onNavigateToSettings: () -> Void
  let onNavigateToAbout: () -> Void

  var body: some View {
    Form {
      Section("Item Info") {
        Text(model.item.name)
          .font(.headline)
      }

      Section("Notes (Model State)") {
        TextField("Add notes...", text: $model.notes, axis: .vertical)
          .lineLimit(3...6)
      }

      Section {
        Toggle("Favorite", isOn: $model.isFavorite)
      }

      Section("Navigate Deeper") {
        Button("Go to Settings") {
          onNavigateToSettings()
        }
        Button("Go to About") {
          onNavigateToAbout()
        }
      }
    }
    .navigationTitle("Detail")
  }
}

// MARK: - Navigation Settings View

struct NavigationSettingsView: View {
  let onPopToRoot: () -> Void

  var body: some View {
    Form {
      Section {
        Text("This is a settings screen accessed via push navigation.")
          .foregroundStyle(.secondary)
      }

      Section {
        Button("Pop to Root") {
          onPopToRoot()
        }
        .foregroundStyle(.red)
      }
    }
    .navigationTitle("Settings")
  }
}

// MARK: - Navigation About View

struct NavigationAboutView: View {
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "info.circle")
        .font(.system(size: 60))
        .foregroundStyle(.blue)

      Text("About")
        .font(.largeTitle)

      Text("This demonstrates deep navigation in NavigationStack.")
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
        .padding()
    }
    .navigationTitle("About")
  }
}

#Preview {
  NavigationTabView(model: NavigationTabModel())
}
