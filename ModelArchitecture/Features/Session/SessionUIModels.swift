import Foundation

/// The UI scope for the signed-out welcome screen.
///
/// Its lifetime is controlled by `AppUIModel.Session`. Replacing the session
/// removes this scope and all local view state below it.
@Observable
final class SignInUIModel {
  private(set) var signInCount = 0

  /// Records a simulated sign-in action before the root changes session scope.
  func recordSignIn() {
    signInCount += 1
  }
}

/// The UI scope for the two-step first-run setup flow.
///
/// The current step is externally represented because it changes the screen
/// structure. Text-field drafts and selections remain local to the stateful view.
@Observable
final class ProfileSetupUIModel {
  /// Mutually exclusive screens within the setup scope.
  enum Step: String, Sendable {
    case profile
    case interests
  }

  var step: Step = .profile

  /// Moves from the profile form to the interests form.
  func continueToInterests() {
    step = .interests
  }

  /// Moves back to the profile form without recreating the setup scope.
  func returnToProfile() {
    step = .profile
  }
}

/// The signed-in session scope, including setup and the main application.
@Observable
final class SignedInUIModel {
  /// Mutually exclusive top-level phases of a signed-in session.
  enum Phase {
    case setup(ProfileSetupUIModel)
    case main(MainUIModel)
  }

  var phase: Phase

  init(phase: Phase = .setup(ProfileSetupUIModel())) {
    self.phase = phase
  }
}

