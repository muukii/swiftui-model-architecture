import Foundation

/// Converts external URLs into high-level `UIIntent` values.
///
/// Parsing is deliberately independent of SwiftUI and the UIModel tree. This
/// keeps URL syntax at the application boundary and makes the routing request
/// usable from push notifications, widgets, and tests as well as deep links.
struct DeepLinkParser: Sendable {
  /// The custom URL scheme registered by the sample application.
  static let scheme = "uimodel-demo"

  /// Parses a URL when it belongs to this application's public route space.
  func intent(for url: URL) -> UIIntent? {
    guard url.scheme?.lowercased() == Self.scheme else {
      return nil
    }

    let components = ([url.host] + url.pathComponents)
      .compactMap { $0 }
      .filter { $0 != "/" && !$0.isEmpty }

    switch components {
    case let route where normalized(route) == ["home"]:
      return .showHome

    case let route where route.count == 3
      && route[0].lowercased() == "home"
      && route[1].lowercased() == "story":
      return .openStory(id: route[2])

    case let route where normalized(route) == ["activity"]:
      return .showActivity(filter: .all)

    case let route where route.count == 2 && route[0].lowercased() == "activity":
      guard let filter = ActivityFilter(rawValue: route[1].lowercased()) else { return nil }
      return .showActivity(filter: filter)

    case let route where route.count == 3
      && route[0].lowercased() == "messages"
      && route[1].lowercased() == "conversation":
      return .openConversation(id: route[2])

    case let route where normalized(route) == ["account"]:
      return .showAccount

    case let route where normalized(route) == ["account", "preferences"]:
      return .openPreferences

    case let route where normalized(route) == ["announcement", "welcome"]:
      return .showAnnouncement

    case let route where normalized(route) == ["restriction", "on"]:
      return .enterRestrictedMode

    case let route where normalized(route) == ["restriction", "off"]:
      return .restoreAccess

    case let route where normalized(route) == ["blocking-notice"]:
      return .showBlockingNotice

    default:
      return nil
    }
  }

  /// Parses user-entered URL text for the Route Lab.
  func intent(for text: String) -> UIIntent? {
    guard let url = URL(string: text.trimmingCharacters(in: .whitespacesAndNewlines)) else {
      return nil
    }
    return intent(for: url)
  }

  private func normalized(_ route: [String]) -> [String] {
    route.map { $0.lowercased() }
  }
}
