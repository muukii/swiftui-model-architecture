import SwiftUI

/// The stateful host for the signed-out screen.
struct SignInScreen: View {
  let uiModel: SignInUIModel
  let pendingIntentTitle: String?
  let onSignIn: () -> Void

  var body: some View {
    SignInStateView(
      pendingIntentTitle: pendingIntentTitle,
      onSignIn: onSignIn
    )
  }
}

/// A value-and-action-only rendering view for the signed-out state.
private struct SignInStateView: View {
  let pendingIntentTitle: String?
  let onSignIn: () -> Void

  var body: some View {
    VStack(spacing: 24) {
      Spacer()

      Image(systemName: "circle.hexagongrid.fill")
        .font(.system(size: 72))
        .foregroundStyle(.indigo.gradient)

      VStack(spacing: 8) {
        Text("UIModel Routing")
          .font(.largeTitle.bold())

        Text("A generic community app used to prototype an externally controllable SwiftUI hierarchy.")
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }

      if let pendingIntentTitle {
        Label {
          Text("Queued route: \(pendingIntentTitle)")
        } icon: {
          Image(systemName: "clock.arrow.circlepath")
        }
        .font(.callout)
        .padding()
        .background(.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
      }

      Button("Sign In", action: onSignIn)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("sign-in-button")

      Spacer()

      Text("Use Route Lab to send a deep link before signing in.")
        .font(.footnote)
        .foregroundStyle(.tertiary)
    }
    .padding(28)
    .frame(maxWidth: 560)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
  }
}

/// The stateful host for profile setup.
///
/// Form drafts are local interaction state. Only `uiModel.step`, which changes
/// the visible screen structure, is stored outside the view.
struct ProfileSetupScreen: View {
  @Bindable var uiModel: ProfileSetupUIModel
  let pendingIntentTitle: String?
  let onComplete: () -> Void

  @State private var displayName = "Taylor"
  @State private var selectedTopics: Set<String> = ["Design"]

  private let topics = ["Design", "Technology", "Local", "Culture"]

  var body: some View {
    NavigationStack {
      Form {
        if let pendingIntentTitle {
          Section {
            Label("Queued: \(pendingIntentTitle)", systemImage: "clock")
              .font(.callout)
          } footer: {
            Text("The route will run after the main tab tree becomes ready.")
          }
        }

        switch uiModel.step {
        case .profile:
          profileStateView
        case .interests:
          interestsStateView
        }
      }
      .navigationTitle(uiModel.step == .profile ? "Create Profile" : "Choose Topics")
      .navigationBarBackButtonHidden()
    }
  }

  private var profileStateView: some View {
    Group {
      Section("Profile") {
        TextField("Display name", text: $displayName)
          .textContentType(.name)
      }

      Section {
        Button("Continue", action: uiModel.continueToInterests)
          .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
          .accessibilityIdentifier("setup-continue-button")
      } footer: {
        Text("The text draft is local @State; it is not needed for external routing.")
      }
    }
  }

  private var interestsStateView: some View {
    Group {
      Section("Topics") {
        ForEach(topics, id: \.self) { topic in
          Button {
            if selectedTopics.contains(topic) {
              selectedTopics.remove(topic)
            } else {
              selectedTopics.insert(topic)
            }
          } label: {
            HStack {
              Text(topic)
                .foregroundStyle(.primary)
              Spacer()
              if selectedTopics.contains(topic) {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundStyle(.indigo)
              }
            }
          }
        }
      }

      Section {
        Button("Finish Setup", action: onComplete)
          .disabled(selectedTopics.isEmpty)
          .accessibilityIdentifier("finish-setup-button")
      }
    }
  }
}

