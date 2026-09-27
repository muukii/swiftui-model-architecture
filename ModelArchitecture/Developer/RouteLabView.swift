import SwiftUI

/// A developer-facing stateful host for exercising external routing scenarios.
struct RouteLabScreen: View {
  let uiModel: RouteLabUIModel
  @Bindable var appUIModel: AppUIModel

  @State private var urlText = "uimodel-demo://messages/conversation/conversation-1"
  @State private var urlValidationMessage: String?

  var body: some View {
    NavigationStack {
      List {
        Section("Current UIModel Tree") {
          Text(appUIModel.treeDescription)
            .font(.caption.monospaced())
            .textSelection(.enabled)

          LabeledContent("Last routing result") {
            Text(appUIModel.routingMessage)
              .multilineTextAlignment(.trailing)
          }

          LabeledContent("Route Lab scope") {
            Text(uiModel.id.uuidString.prefix(8))
              .font(.caption.monospaced())
          }
        }

        Section("Deep Link Presets") {
          routeButton(
            "Open Featured Story",
            systemImage: "doc.richtext",
            intent: .openStory(id: "story-1")
          )
          routeButton(
            "Open Mentions",
            systemImage: "at",
            intent: .showActivity(filter: .mentions)
          )
          routeButton(
            "Open Conversation",
            systemImage: "bubble.left.and.bubble.right",
            intent: .openConversation(id: "conversation-1")
          )
          routeButton(
            "Open Preferences",
            systemImage: "gearshape",
            intent: .openPreferences
          )
        }

        Section("Custom URL") {
          TextField("uimodel-demo://…", text: $urlText)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .font(.caption.monospaced())

          Button("Route URL") {
            urlValidationMessage = nil
            if !appUIModel.handle(urlText: urlText) {
              urlValidationMessage = "Unsupported URL"
            }
          }

          if let urlValidationMessage {
            Text(urlValidationMessage)
              .font(.caption)
              .foregroundStyle(.red)
          }
        }

        Section("Independent Presentation Lanes") {
          routeButton(
            "Show Announcement",
            systemImage: "megaphone",
            intent: .showAnnouncement
          )
          routeButton(
            "Show Blocking Notice",
            systemImage: "exclamationmark.shield",
            intent: .showBlockingNotice
          )
        }

        Section {
          routeButton(
            "Enter Restricted Mode",
            systemImage: "lock.shield",
            intent: .enterRestrictedMode
          )
          routeButton(
            "Restore Access",
            systemImage: "lock.open",
            intent: .restoreAccess
          )

          Button("Reset to Signed Out", role: .destructive) {
            appUIModel.signOut()
          }
        } header: {
          Text("Scenario Controls")
        } footer: {
          Text("A destination intent sent before tabs are ready is retained as pendingIntent and replayed later.")
        }
      }
      .navigationTitle("Route Lab")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done", action: appUIModel.dismissSheet)
        }
      }
    }
  }

  private func routeButton(
    _ title: String,
    systemImage: String,
    intent: UIIntent
  ) -> some View {
    Button {
      appUIModel.dismissSheet()
      appUIModel.send(intent)
    } label: {
      Label(title, systemImage: systemImage)
    }
  }
}
