import Foundation

/// The UI scope shown while the signed-in application prepares its main tree.
@Observable
final class PreparationUIModel {
  let message = "Your workspace is ready to assemble."
}

/// The UI scope shown when the main experience is temporarily unavailable.
@Observable
final class RestrictionUIModel {
  let title = "Access is paused"
  let message = "This separate surface replaces the tabs without turning a tab path into a special case."
}

/// Owns the main application's mutually exclusive surface and retained tab tree.
///
/// `tabs` remains alive while a restriction surface is visible. Restoring access
/// therefore reveals the same per-tab paths rather than reconstructing them.
@Observable
final class MainUIModel {
  /// Coarse-grained surfaces that cannot be visible at the same time.
  enum Surface {
    case preparing(PreparationUIModel)
    case tabs
    case restricted(RestrictionUIModel)
  }

  var surface: Surface
  let tabs: TabContainerUIModel

  init(
    surface: Surface = .preparing(PreparationUIModel()),
    tabs: TabContainerUIModel = TabContainerUIModel()
  ) {
    self.surface = surface
    self.tabs = tabs
  }
}

/// The UI scope for the in-app Route Lab presentation.
@Observable
final class RouteLabUIModel: Identifiable {
  let id = UUID()
}

/// The UI scope for an application-wide announcement sheet.
@Observable
final class AnnouncementUIModel: Identifiable {
  let id = UUID()
  let title: String
  let message: String

  init(
    title: String = "Welcome to the UIModel prototype",
    message: String = "This sheet is owned above the tab hierarchy, so it is independent of every tab's navigation path."
  ) {
    self.title = title
    self.message = message
  }
}

/// A sheet scope presented by `AppUIModel` above the current session tree.
enum AppSheetUIModel: Identifiable {
  case routeLab(RouteLabUIModel)
  case announcement(AnnouncementUIModel)

  var id: UUID {
    switch self {
    case .routeLab(let uiModel): uiModel.id
    case .announcement(let uiModel): uiModel.id
    }
  }
}

/// The UI scope for a blocking layer independent from navigation and sheets.
@Observable
final class BlockingNoticeUIModel: Identifiable {
  let id = UUID()
  let title = "Action required"
  let message = "A blocking layer occupies its own presentation lane in the UIModel tree."
}

