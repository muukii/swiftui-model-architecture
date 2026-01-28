import Foundation

/// Root application model that manages all tab Models.
/// Demonstrates lazy initialization pattern for TabView.
@Observable
class AppModel {
  enum Tab {
    case sheets
    case navigation
    case async
    case settings
  }

  var selectedTab: Tab = .sheets

  // MARK: - Private Storage (Lazy Initialization)

  private var _sheetsTabModel: SheetsTabModel?
  private var _navigationTabModel: NavigationTabModel?
  private var _asyncTabModel: AsyncTabModel?
  private var _settingsTabModel: SettingsTabModel?

  // MARK: - Dependencies

  private let settingsStorage: SettingsStorage

  // MARK: - Initialization

  init(settingsStorage: SettingsStorage = UserDefaultsSettingsStorage()) {
    self.settingsStorage = settingsStorage
  }

  // MARK: - Public Accessors (Lazy Initialization)

  /// Sheets tab demonstrating Sheet Navigation and Confirmation Dialog patterns.
  var sheetsTabModel: SheetsTabModel {
    if _sheetsTabModel == nil {
      _sheetsTabModel = SheetsTabModel()
    }
    return _sheetsTabModel!
  }

  /// Navigation tab demonstrating NavigationStack (path-based) and Model-per-Screen patterns.
  var navigationTabModel: NavigationTabModel {
    if _navigationTabModel == nil {
      _navigationTabModel = NavigationTabModel()
    }
    return _navigationTabModel!
  }

  /// Async tab demonstrating Async Operations, Loading State, and Error Alert patterns.
  var asyncTabModel: AsyncTabModel {
    if _asyncTabModel == nil {
      _asyncTabModel = AsyncTabModel()
    }
    return _asyncTabModel!
  }

  /// Settings tab demonstrating Dependency Injection pattern.
  var settingsTabModel: SettingsTabModel {
    if _settingsTabModel == nil {
      _settingsTabModel = SettingsTabModel(storage: settingsStorage)
    }
    return _settingsTabModel!
  }
}
