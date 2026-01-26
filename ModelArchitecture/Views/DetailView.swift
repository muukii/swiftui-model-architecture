import SwiftUI

struct DetailView: View {
  let model: DetailModel
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        Text("Detail View")
          .font(.largeTitle)

        Text(model.item.name)
          .font(.title2)
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .navigationTitle("Detail")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Close") {
            dismiss()
          }
        }
      }
    }
  }
}

#Preview {
  DetailView(model: DetailModel(item: Item(name: "Preview Item")))
}
