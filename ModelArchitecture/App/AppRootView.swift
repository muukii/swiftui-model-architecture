import SwiftUI

/// Connects the root `AppUIModel` tree to SwiftUI presentation primitives.
struct AppRootView: View {
  @Bindable var uiModel: AppUIModel

  var body: some View {
    ZStack {
      sessionContent

      routeLabButton
        .zIndex(1)

      if let blockingNotice = uiModel.blockingNotice {
        BlockingNoticeView(
          uiModel: blockingNotice,
          onDismiss: uiModel.dismissBlockingNotice
        )
        .transition(.opacity)
        .zIndex(2)
      }
    }
    .sheet(item: $uiModel.sheet) { sheet in
      sheetContent(sheet)
    }
    .animation(.easeInOut(duration: 0.2), value: uiModel.blockingNotice?.id)
  }

  private var routeLabButton: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        Button(action: uiModel.presentRouteLab) {
          Label("Route Lab", systemImage: "point.3.connected.trianglepath.dotted")
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .shadow(color: .black.opacity(0.18), radius: 8, y: 3)
        .padding(.trailing, 16)
        .padding(.bottom, 72)
        .accessibilityIdentifier("route-lab-button")
      }
    }
  }

  @ViewBuilder
  private var sessionContent: some View {
    switch uiModel.session {
    case .signedOut(let signInUIModel):
      SignInScreen(
        uiModel: signInUIModel,
        pendingIntentTitle: uiModel.pendingIntent?.title,
        onSignIn: uiModel.signIn
      )

    case .signedIn(let signedInUIModel):
      SignedInScreen(
        uiModel: signedInUIModel,
        pendingIntentTitle: uiModel.pendingIntent?.title,
        onCompleteSetup: uiModel.completeSetup,
        onFinishPreparation: uiModel.finishPreparation,
        onSendIntent: uiModel.send,
        onSignOut: uiModel.signOut
      )
    }
  }

  @ViewBuilder
  private func sheetContent(_ sheet: AppSheetUIModel) -> some View {
    switch sheet {
    case .routeLab(let routeLabUIModel):
      RouteLabScreen(
        uiModel: routeLabUIModel,
        appUIModel: uiModel
      )

    case .announcement(let announcementUIModel):
      AnnouncementScreen(
        uiModel: announcementUIModel,
        onDismiss: uiModel.dismissSheet
      )
    }
  }
}

/// Renders an application-wide announcement sheet.
private struct AnnouncementScreen: View {
  let uiModel: AnnouncementUIModel
  let onDismiss: () -> Void

  var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        Image(systemName: "megaphone.fill")
          .font(.system(size: 54))
          .foregroundStyle(.indigo)

        Text(uiModel.title)
          .font(.title2.bold())
          .multilineTextAlignment(.center)

        Text(uiModel.message)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)

        Text("Every tab path stays exactly as it was.")
          .font(.callout.monospaced())
          .padding()
          .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
      }
      .padding(28)
      .navigationTitle("Announcement")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done", action: onDismiss)
        }
      }
    }
    .presentationDetents([.medium])
  }
}

/// Renders the independent blocking lane above the current session and sheets.
private struct BlockingNoticeView: View {
  let uiModel: BlockingNoticeUIModel
  let onDismiss: () -> Void

  var body: some View {
    ZStack {
      Color.black.opacity(0.55)
        .ignoresSafeArea()

      VStack(spacing: 18) {
        Image(systemName: "exclamationmark.shield.fill")
          .font(.system(size: 44))
          .foregroundStyle(.orange)

        Text(uiModel.title)
          .font(.title2.bold())

        Text(uiModel.message)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)

        Button("Acknowledge", action: onDismiss)
          .buttonStyle(.borderedProminent)
      }
      .padding(28)
      .frame(maxWidth: 360)
      .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
      .padding()
    }
    .accessibilityAddTraits(.isModal)
  }
}

#Preview {
  AppRootView(uiModel: AppUIModel())
}
