import SwiftUI

/// Selects the visible subtree within a signed-in session.
struct SignedInScreen: View {
  @Bindable var uiModel: SignedInUIModel
  let pendingIntentTitle: String?
  let onCompleteSetup: () -> Void
  let onFinishPreparation: () -> Void
  let onSendIntent: (UIIntent) -> Void
  let onSignOut: () -> Void

  var body: some View {
    switch uiModel.phase {
    case .setup(let setupUIModel):
      ProfileSetupScreen(
        uiModel: setupUIModel,
        pendingIntentTitle: pendingIntentTitle,
        onComplete: onCompleteSetup
      )

    case .main(let mainUIModel):
      MainScreen(
        uiModel: mainUIModel,
        pendingIntentTitle: pendingIntentTitle,
        onFinishPreparation: onFinishPreparation,
        onSendIntent: onSendIntent,
        onSignOut: onSignOut
      )
    }
  }
}

/// Selects the active surface within the main UI scope.
struct MainScreen: View {
  @Bindable var uiModel: MainUIModel
  let pendingIntentTitle: String?
  let onFinishPreparation: () -> Void
  let onSendIntent: (UIIntent) -> Void
  let onSignOut: () -> Void

  var body: some View {
    switch uiModel.surface {
    case .preparing(let preparationUIModel):
      PreparationScreen(
        uiModel: preparationUIModel,
        pendingIntentTitle: pendingIntentTitle,
        onFinish: onFinishPreparation
      )

    case .tabs:
      TabContainerScreen(
        uiModel: uiModel.tabs,
        onSendIntent: onSendIntent,
        onSignOut: onSignOut
      )

    case .restricted(let restrictionUIModel):
      RestrictionScreen(
        uiModel: restrictionUIModel,
        pendingIntentTitle: pendingIntentTitle,
        onRestore: { onSendIntent(.restoreAccess) },
        onSignOut: onSignOut
      )
    }
  }
}

/// Renders the explicit preparation surface before tabs become routable.
private struct PreparationScreen: View {
  let uiModel: PreparationUIModel
  let pendingIntentTitle: String?
  let onFinish: () -> Void

  var body: some View {
    VStack(spacing: 24) {
      ProgressView()
        .controlSize(.large)

      Text("Preparing Your Space")
        .font(.largeTitle.bold())

      Text(uiModel.message)
        .foregroundStyle(.secondary)

      if let pendingIntentTitle {
        Label("Waiting to run: \(pendingIntentTitle)", systemImage: "clock")
          .font(.callout)
          .padding()
          .background(.indigo.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
      }

      Button("Enter App", action: onFinish)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .accessibilityIdentifier("enter-app-button")
    }
    .padding(28)
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
  }
}

/// Renders a replacement main surface while keeping the tab tree retained.
private struct RestrictionScreen: View {
  let uiModel: RestrictionUIModel
  let pendingIntentTitle: String?
  let onRestore: () -> Void
  let onSignOut: () -> Void

  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "lock.shield")
        .font(.system(size: 58))
        .foregroundStyle(.orange)

      Text(uiModel.title)
        .font(.largeTitle.bold())

      Text(uiModel.message)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

      if let pendingIntentTitle {
        Label("Queued: \(pendingIntentTitle)", systemImage: "clock")
          .font(.callout)
      }

      Button("Restore Access", action: onRestore)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)

      Button("Sign Out", role: .destructive, action: onSignOut)
    }
    .padding(28)
    .frame(maxWidth: 540)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGroupedBackground))
  }
}

