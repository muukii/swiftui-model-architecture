import Foundation

/// A public-safe story value displayed by the prototype's Home tab.
struct SampleStory: Identifiable, Hashable, Sendable {
  let id: String
  let title: String
  let summary: String
  let symbol: String
  let tintName: String
}

/// A public-safe activity value displayed by the prototype's Activity tab.
struct SampleActivity: Identifiable, Hashable, Sendable {
  let id: String
  let title: String
  let detail: String
  let filter: ActivityFilter
  let symbol: String
}

/// The externally addressable sections of the Activity tab.
enum ActivityFilter: String, CaseIterable, Identifiable, Hashable, Sendable {
  case all
  case mentions
  case updates

  var id: Self { self }

  var title: String {
    switch self {
    case .all: "All"
    case .mentions: "Mentions"
    case .updates: "Updates"
    }
  }
}

/// A public-safe conversation value displayed by the prototype's Messages tab.
struct SampleConversation: Identifiable, Hashable, Sendable {
  let id: String
  let title: String
  let preview: String
  let symbol: String
}

/// A message value owned by a `ConversationUIModel`.
struct SampleMessage: Identifiable, Hashable, Sendable {
  let id: UUID
  let text: String
  let isFromCurrentUser: Bool

  init(id: UUID = UUID(), text: String, isFromCurrentUser: Bool) {
    self.id = id
    self.text = text
    self.isFromCurrentUser = isFromCurrentUser
  }
}

/// In-memory content used to make the routing prototype independently runnable.
enum SampleContent {
  static let stories: [SampleStory] = [
    SampleStory(
      id: "story-1",
      title: "Designing Calm Notifications",
      summary: "A small set of rules for keeping attention in the user's control.",
      symbol: "bell.badge",
      tintName: "indigo"
    ),
    SampleStory(
      id: "story-2",
      title: "A Shared Garden, One Block at a Time",
      summary: "How a neighborhood group turned an empty lot into a meeting place.",
      symbol: "leaf",
      tintName: "green"
    ),
    SampleStory(
      id: "story-3",
      title: "Notes from a Tiny Design System",
      summary: "Practical tokens and components for a product that is still growing.",
      symbol: "square.grid.2x2",
      tintName: "orange"
    ),
  ]

  static let activities: [SampleActivity] = [
    SampleActivity(
      id: "activity-1",
      title: "You were mentioned in Product Notes",
      detail: "A teammate asked for your thoughts on the latest navigation sketch.",
      filter: .mentions,
      symbol: "at"
    ),
    SampleActivity(
      id: "activity-2",
      title: "Community Guidelines were updated",
      detail: "The shorter summary is now available to review.",
      filter: .updates,
      symbol: "doc.text"
    ),
    SampleActivity(
      id: "activity-3",
      title: "Weekly digest is ready",
      detail: "Catch up on discussions from the spaces you follow.",
      filter: .updates,
      symbol: "sparkles"
    ),
  ]

  static let conversations: [SampleConversation] = [
    SampleConversation(
      id: "conversation-1",
      title: "Project Room",
      preview: "Let's review the prototype tomorrow.",
      symbol: "person.2"
    ),
    SampleConversation(
      id: "conversation-2",
      title: "Design Circle",
      preview: "The new color study is in the shared folder.",
      symbol: "paintpalette"
    ),
    SampleConversation(
      id: "conversation-3",
      title: "Local Group",
      preview: "Saturday's event starts at ten.",
      symbol: "building.2"
    ),
  ]

  static func story(id: String) -> SampleStory {
    stories.first { $0.id == id }
      ?? SampleStory(
        id: id,
        title: "Linked Story",
        summary: "This placeholder demonstrates routing to content that was not preloaded.",
        symbol: "link",
        tintName: "blue"
      )
  }

  static func conversation(id: String) -> SampleConversation {
    conversations.first { $0.id == id }
      ?? SampleConversation(
        id: id,
        title: "Linked Conversation",
        preview: "Opened from an external route.",
        symbol: "link"
      )
  }
}

