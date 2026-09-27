import Foundation

/// Owns the selected tab and all four retained tab UI scopes.
///
/// The child UIModels are created once. Switching tabs changes visibility only;
/// it does not discard another tab's navigation path or screen state.
@Observable
final class TabContainerUIModel {
  /// The stable, externally addressable tabs in the prototype.
  enum Tab: String, CaseIterable, Identifiable, Hashable, Sendable {
    case home
    case activity
    case messages
    case account

    var id: Self { self }

    var title: String {
      rawValue.capitalized
    }

    var symbol: String {
      switch self {
      case .home: "house"
      case .activity: "bell"
      case .messages: "bubble.left.and.bubble.right"
      case .account: "person.crop.circle"
      }
    }
  }

  var selectedTab: Tab = .home
  let home = HomeUIModel()
  let activity = ActivityUIModel()
  let messages = MessagesUIModel()
  let account = AccountUIModel()
}

/// Owns Home's ordered navigation stack.
@Observable
final class HomeUIModel {
  /// Screens pushed above the Home root.
  enum Destination: Hashable {
    case story(StoryUIModel)
  }

  var path: [Destination] = []
  let stories = SampleContent.stories

  /// Pushes a story as an in-app navigation action.
  func open(_ story: SampleStory) {
    path.append(.story(StoryUIModel(story: story)))
  }

  /// Replaces the stack with the canonical path for an external route.
  func route(toStoryID id: String) {
    path = [.story(StoryUIModel(story: SampleContent.story(id: id)))]
  }
}

/// The stateful child scope stored directly in Home's navigation path.
@Observable
final class StoryUIModel: Identifiable, Hashable {
  nonisolated let id: String
  let story: SampleStory
  var isBookmarked = false

  init(story: SampleStory) {
    self.id = story.id
    self.story = story
  }

  nonisolated static func == (lhs: StoryUIModel, rhs: StoryUIModel) -> Bool {
    lhs === rhs
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}

/// Owns Activity's selected section and ordered navigation stack.
@Observable
final class ActivityUIModel {
  /// Screens pushed above the Activity root.
  enum Destination: Hashable {
    case detail(ActivityDetailUIModel)
  }

  var selectedFilter: ActivityFilter = .all
  var path: [Destination] = []
  let activities = SampleContent.activities

  var visibleActivities: [SampleActivity] {
    selectedFilter == .all
      ? activities
      : activities.filter { $0.filter == selectedFilter }
  }

  /// Pushes an activity detail while preserving the selected filter.
  func open(_ activity: SampleActivity) {
    path.append(.detail(ActivityDetailUIModel(activity: activity)))
  }

  /// Selects an externally addressed section and returns to its root.
  func route(to filter: ActivityFilter) {
    selectedFilter = filter
    path.removeAll()
  }
}

/// The child scope stored directly in Activity's navigation path.
@Observable
final class ActivityDetailUIModel: Identifiable, Hashable {
  nonisolated let id: String
  let activity: SampleActivity

  init(activity: SampleActivity) {
    self.id = activity.id
    self.activity = activity
  }

  nonisolated static func == (lhs: ActivityDetailUIModel, rhs: ActivityDetailUIModel) -> Bool {
    lhs === rhs
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}

/// Owns Messages' ordered navigation stack.
@Observable
final class MessagesUIModel {
  /// Screens pushed above the Messages root.
  enum Destination: Hashable {
    case conversation(ConversationUIModel)
  }

  var path: [Destination] = []
  let conversations = SampleContent.conversations

  /// Pushes a conversation as an in-app navigation action.
  func open(_ conversation: SampleConversation) {
    path.append(.conversation(ConversationUIModel(conversation: conversation)))
  }

  /// Replaces the stack with the canonical path for an external route.
  func route(toConversationID id: String) {
    path = [
      .conversation(
        ConversationUIModel(conversation: SampleContent.conversation(id: id))
      )
    ]
  }
}

/// The stateful child scope stored directly in Messages' navigation path.
///
/// Sent messages belong to the screen scope. The unsent composer draft remains
/// local to the stateful SwiftUI host because no external caller needs it.
@Observable
final class ConversationUIModel: Identifiable, Hashable {
  nonisolated let id: String
  let conversation: SampleConversation
  private(set) var messages: [SampleMessage]

  init(conversation: SampleConversation) {
    self.id = conversation.id
    self.conversation = conversation
    self.messages = [
      SampleMessage(
        text: conversation.preview,
        isFromCurrentUser: false
      )
    ]
  }

  /// Commits a non-empty draft to this conversation scope.
  func send(_ draft: String) {
    let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else { return }
    messages.append(SampleMessage(text: text, isFromCurrentUser: true))
  }

  nonisolated static func == (lhs: ConversationUIModel, rhs: ConversationUIModel) -> Bool {
    lhs === rhs
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}

/// Owns Account's ordered navigation stack.
@Observable
final class AccountUIModel {
  /// Screens pushed above the Account root.
  enum Destination: Hashable {
    case preferences(PreferencesUIModel)
  }

  var path: [Destination] = []

  /// Pushes a fresh preferences scope from the Account root.
  func openPreferences() {
    path.append(.preferences(PreferencesUIModel()))
  }

  /// Replaces the stack with the canonical preferences route.
  func routeToPreferences() {
    path = [.preferences(PreferencesUIModel())]
  }
}

/// The stateful child scope stored directly in Account's navigation path.
@Observable
final class PreferencesUIModel: Identifiable, Hashable {
  nonisolated let id = UUID()
  var notificationsEnabled = true
  var compactAppearance = false

  nonisolated static func == (lhs: PreferencesUIModel, rhs: PreferencesUIModel) -> Bool {
    lhs === rhs
  }

  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }
}

