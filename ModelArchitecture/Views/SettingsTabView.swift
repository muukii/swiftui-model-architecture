import SwiftUI

/// Demonstrates Dependency Injection pattern.
///
/// The Model receives its dependencies via initializer injection,
/// allowing different implementations for production vs testing.
struct SettingsTabView: View {
  @Bindable var model: SettingsTabModel

  var body: some View {
    NavigationStack {
      Form {
        Section("Profile") {
          TextField("Username", text: $model.username)
        }

        Section("Preferences") {
          Toggle("Notifications", isOn: $model.notificationsEnabled)

          Picker("Theme", selection: $model.theme) {
            ForEach(Theme.allCases) { theme in
              Text(theme.displayName).tag(theme)
            }
          }
        }

        Section {
          HStack {
            Button("Save") {
              model.save()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!model.hasUnsavedChanges)

            Spacer()

            Button("Reset") {
              model.reset()
            }
            .foregroundStyle(.red)
            .disabled(!model.hasUnsavedChanges)
          }
        }

        Section("About Dependency Injection") {
          Text("This Model receives a SettingsStorage via initializer injection. In production, UserDefaultsSettingsStorage is used. In previews/tests, MockSettingsStorage can be injected.")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      .navigationTitle("Settings")
    }
  }
}

#Preview("Production Storage") {
  SettingsTabView(model: SettingsTabModel(storage: UserDefaultsSettingsStorage()))
}

#Preview("Mock Storage") {
  SettingsTabView(model: SettingsTabModel(storage: MockSettingsStorage()))
}
