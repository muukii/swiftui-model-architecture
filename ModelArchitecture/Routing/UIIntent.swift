import Foundation

/// A one-shot request to change the application's UI structure.
///
/// An intent describes what the caller wants to reach. `AppUIModel` resolves that
/// request into durable UI state such as a selected tab, a navigation path, or an
/// app-wide presentation.
enum UIIntent: Equatable, Sendable {
  case showHome
  case openStory(id: String)
  case showActivity(filter: ActivityFilter)
  case openConversation(id: String)
  case showAccount
  case openPreferences
  case showAnnouncement
  case enterRestrictedMode
  case restoreAccess
  case showBlockingNotice

  /// A concise description suitable for diagnostics and the Route Lab.
  var title: String {
    switch self {
    case .showHome:
      "Show Home"
    case .openStory(let id):
      "Open Story (\(id))"
    case .showActivity(let filter):
      "Show Activity (\(filter.title))"
    case .openConversation(let id):
      "Open Conversation (\(id))"
    case .showAccount:
      "Show Account"
    case .openPreferences:
      "Open Preferences"
    case .showAnnouncement:
      "Show Announcement"
    case .enterRestrictedMode:
      "Enter Restricted Mode"
    case .restoreAccess:
      "Restore Access"
    case .showBlockingNotice:
      "Show Blocking Notice"
    }
  }

  /// Whether the intent requires the signed-in tab hierarchy to be ready.
  var requiresReadyTabs: Bool {
    switch self {
    case .showHome,
         .openStory,
         .showActivity,
         .openConversation,
         .showAccount,
         .openPreferences,
         .enterRestrictedMode:
      true
    case .showAnnouncement, .restoreAccess, .showBlockingNotice:
      false
    }
  }
}

