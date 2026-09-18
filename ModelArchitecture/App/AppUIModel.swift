import Foundation

/// The root UIModel for the application's complete externally controllable UI.
///
/// The tree records durable UI scopes and their relationships. Callers send
/// one-shot `UIIntent` values; this root resolves each intent against the current
/// session and mutates the lowest-level UI representation needed by SwiftUI.
@Observable
final class AppUIModel {
  /// Mutually exclusive application session scopes.
  enum Session {
    case signedOut(SignInUIModel)
    case signedIn(SignedInUIModel)
  }

  var session: Session
  var sheet: AppSheetUIModel?
  var blockingNotice: BlockingNoticeUIModel?

  private(set) var pendingIntent: UIIntent?
  private(set) var routingMessage = "No route has been handled yet."

  private let deepLinkParser = DeepLinkParser()

  init(session: Session = .signedOut(SignInUIModel())) {
    self.session = session
  }

  // MARK: - Session flow

  /// Replaces the signed-out scope with the signed-in setup scope.
  func signIn() {
    guard case .signedOut(let signInUIModel) = session else { return }
    signInUIModel.recordSignIn()
    session = .signedIn(SignedInUIModel())
    routingMessage = "Created signed-in setup scope."
  }

  /// Replaces setup with a preparing main scope.
  func completeSetup() {
    guard case .signedIn(let signedInUIModel) = session,
          case .setup = signedInUIModel.phase
    else { return }

    signedInUIModel.phase = .main(MainUIModel())
    routingMessage = "Created the main scope; its tabs are retained while preparation is visible."
  }

  /// Makes the retained tab tree visible and replays the latest deferred intent.
  func finishPreparation() {
    guard let mainUIModel else { return }
    mainUIModel.surface = .tabs
    routingMessage = "The tab tree is ready."
    replayPendingIntentIfNeeded()
  }

  /// Destroys the signed-in tree and returns to a fresh signed-out scope.
  func signOut() {
    session = .signedOut(SignInUIModel())
    sheet = nil
    blockingNotice = nil
    pendingIntent = nil
    routingMessage = "Destroyed the signed-in UIModel tree."
  }

  // MARK: - External routing

  /// Parses and handles an application deep link.
  @discardableResult
  func handle(url: URL) -> Bool {
    guard let intent = deepLinkParser.intent(for: url) else {
      routingMessage = "Ignored unsupported URL: \(url.absoluteString)"
      return false
    }

    send(intent)
    return true
  }

  /// Parses URL text entered in Route Lab and handles the resulting intent.
  @discardableResult
  func handle(urlText: String) -> Bool {
    guard let intent = deepLinkParser.intent(for: urlText) else {
      routingMessage = "The URL does not match a supported route."
      return false
    }

    sheet = nil
    send(intent)
    return true
  }

  /// Resolves a high-level request against the current UIModel tree.
  func send(_ intent: UIIntent) {
    if case .enterRestrictedMode = intent,
       let mainUIModel,
       case .restricted = mainUIModel.surface {
      if pendingIntent == intent {
        pendingIntent = nil
      }
      routingMessage = "Restricted mode is already the active surface."
      return
    }

    if intent.requiresReadyTabs, readyTabs == nil {
      pendingIntent = intent
      sheet = nil
      routingMessage = "Deferred \(intent.title) until the tab tree is ready."
      return
    }

    switch intent {
    case .showHome:
      guard let tabs = readyTabs else { return }
      tabs.selectedTab = .home
      tabs.home.path.removeAll()
      routingMessage = "Selected Home and replaced its path with the root path."

    case .openStory(let id):
      guard let tabs = readyTabs else { return }
      tabs.selectedTab = .home
      tabs.home.route(toStoryID: id)
      routingMessage = "Selected Home and installed the canonical story path."

    case .showActivity(let filter):
      guard let tabs = readyTabs else { return }
      tabs.selectedTab = .activity
      tabs.activity.route(to: filter)
      routingMessage = "Selected the \(filter.title) activity section."

    case .openConversation(let id):
      guard let tabs = readyTabs else { return }
      tabs.selectedTab = .messages
      tabs.messages.route(toConversationID: id)
      routingMessage = "Selected Messages and installed the canonical conversation path."

    case .showAccount:
      guard let tabs = readyTabs else { return }
      tabs.selectedTab = .account
      tabs.account.path.removeAll()
      routingMessage = "Selected Account and replaced its path with the root path."

    case .openPreferences:
      guard let tabs = readyTabs else { return }
      tabs.selectedTab = .account
      tabs.account.routeToPreferences()
      routingMessage = "Selected Account and installed the canonical preferences path."

    case .showAnnouncement:
      guard blockingNotice == nil else {
        routingMessage = "Kept the blocking layer visible instead of presenting a sheet above it."
        return
      }
      sheet = .announcement(AnnouncementUIModel())
      routingMessage = "Presented an app-wide sheet outside the tab paths."

    case .enterRestrictedMode:
      guard let mainUIModel else { return }
      mainUIModel.surface = .restricted(RestrictionUIModel())
      routingMessage = "Replaced the visible tabs with a restricted surface; tab scopes remain alive."

    case .restoreAccess:
      guard let mainUIModel,
            case .restricted = mainUIModel.surface
      else {
        routingMessage = "Restore Access had no restricted surface to replace."
        return
      }
      mainUIModel.surface = .tabs
      routingMessage = "Restored the retained tab tree."
      replayPendingIntentIfNeeded()

    case .showBlockingNotice:
      sheet = nil
      blockingNotice = BlockingNoticeUIModel()
      routingMessage = "Presented a blocking layer in its own UI lane."
    }

    if pendingIntent == intent {
      pendingIntent = nil
    }
  }

  // MARK: - App-wide presentations

  /// Presents the developer Route Lab as an app-level sheet scope.
  func presentRouteLab() {
    guard blockingNotice == nil else { return }
    sheet = .routeLab(RouteLabUIModel())
  }

  /// Removes the current app-level sheet scope.
  func dismissSheet() {
    sheet = nil
  }

  /// Removes the current blocking scope.
  func dismissBlockingNotice() {
    blockingNotice = nil
  }

  // MARK: - Diagnostics

  /// A live textual projection of the durable UIModel tree.
  var treeDescription: String {
    var lines = ["AppUIModel"]

    switch session {
    case .signedOut:
      lines.append("├─ session: signedOut(SignInUIModel)")

    case .signedIn(let signedInUIModel):
      lines.append("├─ session: signedIn(SignedInUIModel)")
      switch signedInUIModel.phase {
      case .setup(let setupUIModel):
        lines.append("│  └─ phase: setup(\(setupUIModel.step.rawValue))")

      case .main(let mainUIModel):
        lines.append("│  └─ phase: main(MainUIModel)")
        switch mainUIModel.surface {
        case .preparing:
          lines.append("│     ├─ surface: preparing")
        case .tabs:
          lines.append("│     ├─ surface: tabs")
        case .restricted:
          lines.append("│     ├─ surface: restricted")
        }
        lines.append("│     └─ retained tabs: \(tabSummary(mainUIModel.tabs))")
      }
    }

    lines.append("├─ sheet: \(sheetName)")
    lines.append("├─ blocking: \(blockingNotice == nil ? "nil" : "BlockingNoticeUIModel")")
    lines.append("└─ pendingIntent: \(pendingIntent?.title ?? "nil")")
    return lines.joined(separator: "\n")
  }

  private var mainUIModel: MainUIModel? {
    guard case .signedIn(let signedInUIModel) = session,
          case .main(let mainUIModel) = signedInUIModel.phase
    else { return nil }
    return mainUIModel
  }

  private var readyTabs: TabContainerUIModel? {
    guard let mainUIModel,
          case .tabs = mainUIModel.surface
    else { return nil }
    return mainUIModel.tabs
  }

  private var sheetName: String {
    switch sheet {
    case .routeLab: "RouteLabUIModel"
    case .announcement: "AnnouncementUIModel"
    case nil: "nil"
    }
  }

  private func replayPendingIntentIfNeeded() {
    guard let pendingIntent else { return }
    self.pendingIntent = nil
    send(pendingIntent)
  }

  private func tabSummary(_ tabs: TabContainerUIModel) -> String {
    [
      "selected=\(tabs.selectedTab.rawValue)",
      "home.path=\(tabs.home.path.count)",
      "activity.path=\(tabs.activity.path.count)",
      "messages.path=\(tabs.messages.path.count)",
      "account.path=\(tabs.account.path.count)",
    ].joined(separator: ", ")
  }
}
