import Foundation

// MARK: - Settings Storage Protocol

/// Protocol for settings persistence. Demonstrates Dependency Injection pattern.
protocol SettingsStorage {
  var notificationsEnabled: Bool { get set }
  var theme: Theme { get set }
  var username: String { get set }
}

// MARK: - Theme

enum Theme: String, CaseIterable, Identifiable {
  case system
  case light
  case dark

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .system: return "System"
    case .light: return "Light"
    case .dark: return "Dark"
    }
  }
}

// MARK: - UserDefaults Implementation

/// Default implementation using UserDefaults for persistence.
class UserDefaultsSettingsStorage: SettingsStorage {
  private let defaults = UserDefaults.standard

  private enum Keys {
    static let notificationsEnabled = "settings.notificationsEnabled"
    static let theme = "settings.theme"
    static let username = "settings.username"
  }

  var notificationsEnabled: Bool {
    get { defaults.bool(forKey: Keys.notificationsEnabled) }
    set { defaults.set(newValue, forKey: Keys.notificationsEnabled) }
  }

  var theme: Theme {
    get {
      guard let rawValue = defaults.string(forKey: Keys.theme),
            let theme = Theme(rawValue: rawValue) else {
        return .system
      }
      return theme
    }
    set { defaults.set(newValue.rawValue, forKey: Keys.theme) }
  }

  var username: String {
    get { defaults.string(forKey: Keys.username) ?? "User" }
    set { defaults.set(newValue, forKey: Keys.username) }
  }
}

// MARK: - Mock Implementation for Testing

/// Mock implementation for testing and previews.
class MockSettingsStorage: SettingsStorage {
  var notificationsEnabled: Bool = true
  var theme: Theme = .system
  var username: String = "Preview User"
}

// MARK: - Settings Tab Model

/// Demonstrates Dependency Injection pattern.
///
/// The Model receives its storage dependency via initializer injection,
/// allowing different implementations for production vs testing.
@Observable
class SettingsTabModel {
  private let storage: SettingsStorage

  var notificationsEnabled: Bool
  var theme: Theme
  var username: String

  /// Tracks if there are unsaved changes.
  var hasUnsavedChanges: Bool {
    notificationsEnabled != storage.notificationsEnabled ||
    theme != storage.theme ||
    username != storage.username
  }

  init(storage: SettingsStorage) {
    self.storage = storage
    // Load initial values from storage
    self.notificationsEnabled = storage.notificationsEnabled
    self.theme = storage.theme
    self.username = storage.username
  }

  /// Save current settings to storage.
  func save() {
    var mutableStorage = storage
    mutableStorage.notificationsEnabled = notificationsEnabled
    mutableStorage.theme = theme
    mutableStorage.username = username
  }

  /// Reset to last saved values.
  func reset() {
    notificationsEnabled = storage.notificationsEnabled
    theme = storage.theme
    username = storage.username
  }
}
