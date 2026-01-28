import SwiftUI

/// Demonstrates Async Operations, Loading State, Error Alert, and @State patterns.
///
/// Patterns demonstrated:
/// - Loading State: `model.isLoading` controls loading UI
/// - Error Alert: `model.errorAlert` controls error presentation
/// - @State: Local animation state for ephemeral UI
struct AsyncTabView: View {
  @Bindable var model: AsyncTabModel

  // MARK: - @State for Ephemeral UI
  // Animation state is ephemeral - it doesn't need to survive navigation
  // or be shared with other parts of the app. This is the proper use of @State.
  @State private var showSuccessAnimation = false

  var body: some View {
    NavigationStack {
      ZStack {
        contentView
        if model.isLoading {
          loadingOverlay
        }
      }
      .navigationTitle("Async")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            Task {
              await model.addItem()
              triggerSuccessAnimation()
            }
          } label: {
            Image(systemName: "plus")
          }
          .disabled(model.isLoading)
        }
      }
      // MARK: - Error Alert Pattern
      .alert(
        model.errorAlert?.title ?? "Error",
        isPresented: Binding(
          get: { model.errorAlert != nil },
          set: { if !$0 { model.dismissError() } }
        ),
        presenting: model.errorAlert
      ) { _ in
        Button("OK") {
          model.dismissError()
        }
      } message: { error in
        Text(error.message)
      }
      // MARK: - Success Animation Overlay
      .overlay {
        if showSuccessAnimation {
          successAnimationView
        }
      }
    }
  }

  // MARK: - Content View

  @ViewBuilder
  private var contentView: some View {
    if model.items.isEmpty && !model.isLoading {
      emptyStateView
    } else {
      itemListView
    }
  }

  private var emptyStateView: some View {
    ContentUnavailableView {
      Label("No Items", systemImage: "tray")
    } description: {
      Text("Tap the button below to load items.")
    } actions: {
      Button("Load Items") {
        Task {
          await model.loadItems()
        }
      }
      .buttonStyle(.borderedProminent)
    }
  }

  private var itemListView: some View {
    List(model.items) { item in
      HStack {
        Text(item.name)
        Spacer()
      }
      .swipeActions(edge: .trailing, allowsFullSwipe: false) {
        Button("Delete", role: .destructive) {
          Task {
            await model.deleteItem(item)
          }
        }
      }
    }
    .refreshable {
      await model.refresh()
    }
  }

  // MARK: - Loading Overlay

  private var loadingOverlay: some View {
    ZStack {
      Color.black.opacity(0.3)
        .ignoresSafeArea()
      ProgressView()
        .scaleEffect(1.5)
        .tint(.white)
    }
  }

  // MARK: - Success Animation (Ephemeral @State Example)

  private var successAnimationView: some View {
    Image(systemName: "checkmark.circle.fill")
      .font(.system(size: 80))
      .foregroundStyle(.green)
      .transition(.scale.combined(with: .opacity))
  }

  private func triggerSuccessAnimation() {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
      showSuccessAnimation = true
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
      withAnimation(.easeOut(duration: 0.2)) {
        showSuccessAnimation = false
      }
    }
  }
}

#Preview("Empty State") {
  AsyncTabView(model: AsyncTabModel())
}

#Preview("With Items") {
  let model = AsyncTabModel()
  model.items = [
    Item(name: "Preview Item 1"),
    Item(name: "Preview Item 2"),
  ]
  return AsyncTabView(model: model)
}
