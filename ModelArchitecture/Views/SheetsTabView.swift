import SwiftUI

/// Demonstrates Sheet Navigation and Confirmation Dialog patterns.
///
/// Patterns demonstrated:
/// - Sheet Navigation: Controlled by `model.detailModel` property
/// - Confirmation Dialog: Controlled by `model.deleteConfirmation` property
struct SheetsTabView: View {
  @Bindable var model: SheetsTabModel

  var body: some View {
    NavigationStack {
      List(model.items) { item in
        Button(item.name) {
          model.showDetail(item: item)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
          Button("Delete", role: .destructive) {
            model.requestDelete(item)
          }
        }
      }
      .navigationTitle("Sheets")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            model.addItem()
          } label: {
            Image(systemName: "plus")
          }
        }
      }
    }
    // MARK: - Sheet Navigation Pattern
    .sheet(item: $model.detailModel) { detail in
      DetailView(model: detail)
    }
    // MARK: - Confirmation Dialog Pattern
    .confirmationDialog(
      "Delete Item",
      isPresented: Binding(
        get: { model.deleteConfirmation != nil },
        set: { if !$0 { model.cancelDelete() } }
      ),
      presenting: model.deleteConfirmation
    ) { item in
      Button("Delete \(item.name)", role: .destructive) {
        model.executeDelete()
      }
      Button("Cancel", role: .cancel) {
        model.cancelDelete()
      }
    } message: { item in
      Text("Are you sure you want to delete \(item.name)?")
    }
  }
}

#Preview {
  SheetsTabView(model: SheetsTabModel())
}
