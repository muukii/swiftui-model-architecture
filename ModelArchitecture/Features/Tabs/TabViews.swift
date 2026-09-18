import SwiftUI

/// Renders four retained tab hosts and binds their shared selection.
struct TabContainerScreen: View {
  @Bindable var uiModel: TabContainerUIModel
  let onSendIntent: (UIIntent) -> Void
  let onSignOut: () -> Void

  var body: some View {
    TabView(selection: $uiModel.selectedTab) {
      HomeScreen(
        uiModel: uiModel.home,
        onShowAnnouncement: { onSendIntent(.showAnnouncement) }
      )
      .tabItem {
        Label(TabContainerUIModel.Tab.home.title, systemImage: TabContainerUIModel.Tab.home.symbol)
      }
      .tag(TabContainerUIModel.Tab.home)

      ActivityScreen(uiModel: uiModel.activity)
        .tabItem {
          Label(
            TabContainerUIModel.Tab.activity.title,
            systemImage: TabContainerUIModel.Tab.activity.symbol
          )
        }
        .tag(TabContainerUIModel.Tab.activity)

      MessagesScreen(uiModel: uiModel.messages)
        .tabItem {
          Label(
            TabContainerUIModel.Tab.messages.title,
            systemImage: TabContainerUIModel.Tab.messages.symbol
          )
        }
        .tag(TabContainerUIModel.Tab.messages)

      AccountScreen(
        uiModel: uiModel.account,
        onEnterRestrictedMode: { onSendIntent(.enterRestrictedMode) },
        onSignOut: onSignOut
      )
      .tabItem {
        Label(
          TabContainerUIModel.Tab.account.title,
          systemImage: TabContainerUIModel.Tab.account.symbol
        )
      }
      .tag(TabContainerUIModel.Tab.account)
    }
  }
}

/// The stateful host for Home and its navigation stack.
struct HomeScreen: View {
  @Bindable var uiModel: HomeUIModel
  let onShowAnnouncement: () -> Void

  var body: some View {
    NavigationStack(path: $uiModel.path) {
      HomeStateView(stories: uiModel.stories, onSelect: uiModel.open)
        .navigationTitle("Home")
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button(action: onShowAnnouncement) {
              Image(systemName: "megaphone")
            }
            .accessibilityLabel("Show Announcement")
          }
        }
        .navigationDestination(for: HomeUIModel.Destination.self) { destination in
          switch destination {
          case .story(let storyUIModel):
            StoryScreen(uiModel: storyUIModel)
          }
        }
    }
  }
}

/// A value-and-action-only rendering view for the Home root.
private struct HomeStateView: View {
  let stories: [SampleStory]
  let onSelect: (SampleStory) -> Void

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 14) {
        ForEach(stories) { story in
          Button {
            onSelect(story)
          } label: {
            HStack(spacing: 16) {
              Image(systemName: story.symbol)
                .font(.title2)
                .frame(width: 48, height: 48)
                .foregroundStyle(story.tint)
                .background(story.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))

              VStack(alignment: .leading, spacing: 5) {
                Text(story.title)
                  .font(.headline)
                  .foregroundStyle(.primary)
                  .multilineTextAlignment(.leading)

                Text(story.summary)
                  .font(.subheadline)
                  .foregroundStyle(.secondary)
                  .lineLimit(2)
                  .multilineTextAlignment(.leading)
              }

              Spacer(minLength: 0)

              Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 18))
          }
          .buttonStyle(.plain)
          .accessibilityIdentifier("story-\(story.id)")
        }
      }
      .padding()
    }
    .background(Color(.systemGroupedBackground))
  }
}

/// The stateful host for a story UI scope stored in Home's path.
private struct StoryScreen: View {
  @Bindable var uiModel: StoryUIModel

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 22) {
        Image(systemName: uiModel.story.symbol)
          .font(.system(size: 52))
          .foregroundStyle(uiModel.story.tint)

        Text(uiModel.story.title)
          .font(.largeTitle.bold())

        Text(uiModel.story.summary)
          .font(.title3)
          .foregroundStyle(.secondary)

        Divider()

        Text("The navigation path owns this StoryUIModel instance. Bookmark state survives tab switches and disappears naturally when the path is popped.")
          .font(.body)

        Toggle("Bookmarked", isOn: $uiModel.isBookmarked)
          .padding()
          .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
      }
      .padding(24)
    }
    .navigationTitle("Story")
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// The stateful host for Activity, its section selection, and its path.
struct ActivityScreen: View {
  @Bindable var uiModel: ActivityUIModel

  var body: some View {
    NavigationStack(path: $uiModel.path) {
      List {
        Section {
          Picker("Activity section", selection: $uiModel.selectedFilter) {
            ForEach(ActivityFilter.allCases) { filter in
              Text(filter.title).tag(filter)
            }
          }
          .pickerStyle(.segmented)
          .accessibilityIdentifier("activity-filter")
        }

        Section(uiModel.selectedFilter.title) {
          ForEach(uiModel.visibleActivities) { activity in
            Button {
              uiModel.open(activity)
            } label: {
              Label {
                VStack(alignment: .leading, spacing: 4) {
                  Text(activity.title)
                    .foregroundStyle(.primary)
                  Text(activity.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                }
              } icon: {
                Image(systemName: activity.symbol)
                  .foregroundStyle(.indigo)
              }
            }
          }
        }
      }
      .navigationTitle("Activity")
      .navigationDestination(for: ActivityUIModel.Destination.self) { destination in
        switch destination {
        case .detail(let detailUIModel):
          ActivityDetailScreen(uiModel: detailUIModel)
        }
      }
    }
  }
}

/// Renders a child UI scope stored in Activity's path.
private struct ActivityDetailScreen: View {
  let uiModel: ActivityDetailUIModel

  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: uiModel.activity.symbol)
        .font(.system(size: 48))
        .foregroundStyle(.indigo)

      Text(uiModel.activity.title)
        .font(.title2.bold())
        .multilineTextAlignment(.center)

      Text(uiModel.activity.detail)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .padding(24)
    .navigationTitle("Activity Detail")
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// The stateful host for Messages and its navigation stack.
struct MessagesScreen: View {
  @Bindable var uiModel: MessagesUIModel

  var body: some View {
    NavigationStack(path: $uiModel.path) {
      List(uiModel.conversations) { conversation in
        Button {
          uiModel.open(conversation)
        } label: {
          HStack(spacing: 14) {
            Image(systemName: conversation.symbol)
              .font(.title3)
              .frame(width: 42, height: 42)
              .background(.indigo.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
              Text(conversation.title)
                .font(.headline)
                .foregroundStyle(.primary)
              Text(conversation.preview)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }
          }
        }
        .accessibilityIdentifier("conversation-\(conversation.id)")
      }
      .navigationTitle("Messages")
      .navigationDestination(for: MessagesUIModel.Destination.self) { destination in
        switch destination {
        case .conversation(let conversationUIModel):
          ConversationScreen(uiModel: conversationUIModel)
        }
      }
    }
  }
}

/// The stateful host for a conversation scope.
///
/// The composer draft and focus are local interaction state. Committed messages
/// are sent to the path-owned `ConversationUIModel`.
private struct ConversationScreen: View {
  @Bindable var uiModel: ConversationUIModel
  @State private var draft = ""
  @FocusState private var composerIsFocused: Bool

  var body: some View {
    ConversationStateView(
      messages: uiModel.messages,
      draft: $draft,
      composerIsFocused: $composerIsFocused,
      onSend: sendDraft
    )
    .navigationTitle(uiModel.conversation.title)
    .navigationBarTitleDisplayMode(.inline)
  }

  private func sendDraft() {
    uiModel.send(draft)
    draft = ""
  }
}

/// A rendering view for conversation values and actions.
private struct ConversationStateView: View {
  let messages: [SampleMessage]
  @Binding var draft: String
  var composerIsFocused: FocusState<Bool>.Binding
  let onSend: () -> Void

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 10) {
        ForEach(messages) { message in
          HStack {
            if message.isFromCurrentUser { Spacer(minLength: 44) }

            Text(message.text)
              .padding(.horizontal, 14)
              .padding(.vertical, 10)
              .foregroundStyle(message.isFromCurrentUser ? .white : .primary)
              .background(
                message.isFromCurrentUser ? Color.indigo : Color(.secondarySystemBackground),
                in: RoundedRectangle(cornerRadius: 16)
              )

            if !message.isFromCurrentUser { Spacer(minLength: 44) }
          }
        }
      }
      .padding()
    }
    .background(Color(.systemGroupedBackground))
    .safeAreaInset(edge: .bottom) {
      HStack(spacing: 10) {
        TextField("Message", text: $draft, axis: .vertical)
          .textFieldStyle(.roundedBorder)
          .focused(composerIsFocused)

        Button("Send", action: onSend)
          .buttonStyle(.borderedProminent)
          .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      }
      .padding()
      .background(.bar)
    }
  }
}

/// The stateful host for Account and its navigation stack.
struct AccountScreen: View {
  @Bindable var uiModel: AccountUIModel
  let onEnterRestrictedMode: () -> Void
  let onSignOut: () -> Void

  var body: some View {
    NavigationStack(path: $uiModel.path) {
      List {
        Section("Profile") {
          Label("Taylor", systemImage: "person.crop.circle.fill")
          Label("Community Member", systemImage: "checkmark.seal")
        }

        Section("Navigation") {
          Button("Preferences", action: uiModel.openPreferences)
            .accessibilityIdentifier("open-preferences-button")
        }

        Section("App surfaces") {
          Button("Enter Restricted Mode", action: onEnterRestrictedMode)
          Button("Sign Out", role: .destructive, action: onSignOut)
        }
      }
      .navigationTitle("Account")
      .navigationDestination(for: AccountUIModel.Destination.self) { destination in
        switch destination {
        case .preferences(let preferencesUIModel):
          PreferencesScreen(uiModel: preferencesUIModel)
        }
      }
    }
  }
}

/// The stateful host for a preferences scope stored in Account's path.
private struct PreferencesScreen: View {
  @Bindable var uiModel: PreferencesUIModel

  var body: some View {
    Form {
      Section("Notifications") {
        Toggle("Notifications", isOn: $uiModel.notificationsEnabled)
      }

      Section("Appearance") {
        Toggle("Compact Appearance", isOn: $uiModel.compactAppearance)
      }

      Section {
        Text("This PreferencesUIModel exists only while its destination remains in Account's path.")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .navigationTitle("Preferences")
  }
}

private extension SampleStory {
  var tint: Color {
    switch tintName {
    case "green": .green
    case "orange": .orange
    case "blue": .blue
    default: .indigo
    }
  }
}

