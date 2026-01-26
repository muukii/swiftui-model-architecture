# Practices

Concrete patterns and practices for Model-Driven Architecture.

---

## 1. Sheet Navigation Pattern

### Basic Pattern

```swift
@Observable
class ParentModel {
  var childModel: ChildModel?

  func showChild() {
    childModel = ChildModel()
  }

  func dismissChild() {
    childModel = nil
  }
}

struct ParentView: View {
  @Bindable var model: ParentModel

  var body: some View {
    Button("Show Sheet") {
      model.showChild()
    }
    .sheet(item: $model.childModel) { child in
      ChildView(model: child)
    }
  }
}
```

### With Data Passing

```swift
@Observable
class HomeModel {
  var items: [Item] = []
  var detailModel: DetailModel?

  func showDetail(for item: Item) {
    detailModel = DetailModel(item: item)
  }
}
```

### Dismissing from Child

Option 1: Parent provides dismiss callback

```swift
@Observable
class DetailModel: Identifiable {
  let id = UUID()
  let item: Item
  var onDismiss: (() -> Void)?

  init(item: Item, onDismiss: @escaping () -> Void) {
    self.item = item
    self.onDismiss = onDismiss
  }

  func done() {
    onDismiss?()
  }
}
```

Option 2: Use SwiftUI's `@Environment(\.dismiss)`

```swift
struct DetailView: View {
  let model: DetailModel
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    Button("Close") {
      dismiss()
    }
  }
}
```

---

## 2. NavigationStack Pattern

### Path-based Navigation

```swift
@Observable
class NavigationModel {
  var path: [Destination] = []

  enum Destination: Hashable {
    case detail(Item)
    case settings
    case profile(User)
  }

  func push(_ destination: Destination) {
    path.append(destination)
  }

  func pop() {
    path.removeLast()
  }

  func popToRoot() {
    path.removeAll()
  }
}
```

```swift
struct RootView: View {
  @Bindable var model: NavigationModel

  var body: some View {
    NavigationStack(path: $model.path) {
      HomeContent()
        .navigationDestination(for: NavigationModel.Destination.self) { dest in
          switch dest {
          case .detail(let item):
            DetailView(item: item)
          case .settings:
            SettingsView()
          case .profile(let user):
            ProfileView(user: user)
          }
        }
    }
  }
}
```

### Model-per-Screen in NavigationStack

For complex screens that need their own Models:

```swift
@Observable
class AppModel {
  var navigationPath: [NavigationDestination] = []
  private var detailModels: [Item.ID: DetailModel] = [:]

  func detailModel(for item: Item) -> DetailModel {
    if let existing = detailModels[item.id] {
      return existing
    }
    let model = DetailModel(item: item)
    detailModels[item.id] = model
    return model
  }
}
```

---

## 3. Local State (@State) Guidelines

### When to Use @State

Use `@State` for:
- **Ephemeral UI state** that doesn't affect business logic
- **Animation state**
- **Focus state**
- **Temporary input** before committing

```swift
struct FormView: View {
  let model: FormModel

  @State private var isShowingConfirmation = false  // UI-only
  @State private var textFieldFocus: Bool = false   // Focus state
  @FocusState private var focusedField: Field?      // Focus management

  var body: some View {
    // ...
  }
}
```

### When NOT to Use @State

Do NOT use `@State` for:
- **Business data** - belongs in Model
- **Navigation state** - belongs in Model
- **Shared state** - belongs in Model
- **State that needs to survive view recreation**

```swift
// BAD
struct HomeView: View {
  @State var items: [Item] = []  // Should be in Model
}

// GOOD
struct HomeView: View {
  let model: HomeModel  // Model owns items

  var body: some View {
    List(model.items) { ... }
  }
}
```

---

## 4. Model Dependencies

### Dependency Injection via Initializer

```swift
@Observable
class HomeModel {
  private let apiClient: APIClient
  private let storage: Storage

  init(apiClient: APIClient, storage: Storage) {
    self.apiClient = apiClient
    self.storage = storage
  }
}
```

### Passing Dependencies Down the Model Graph

```swift
@Observable
class AppModel {
  let apiClient: APIClient
  let storage: Storage

  var homeModel: HomeModel

  init(apiClient: APIClient, storage: Storage) {
    self.apiClient = apiClient
    self.storage = storage
    self.homeModel = HomeModel(apiClient: apiClient, storage: storage)
  }

  func createDetailModel(item: Item) -> DetailModel {
    DetailModel(item: item, apiClient: apiClient)
  }
}
```

### Using Environment for Cross-cutting Concerns

```swift
// For truly global dependencies
struct APIClientKey: EnvironmentKey {
  static let defaultValue: APIClient = .live
}

extension EnvironmentValues {
  var apiClient: APIClient {
    get { self[APIClientKey.self] }
    set { self[APIClientKey.self] = newValue }
  }
}
```

---

## 5. Model Identifiability

### For sheet(item:) Usage

Models used with `sheet(item:)` must conform to `Identifiable`:

```swift
@Observable
class DetailModel: Identifiable {
  let id = UUID()
  // ...
}
```

### For NavigationStack

Destinations must be `Hashable`:

```swift
enum Destination: Hashable {
  case detail(itemId: UUID)  // Use ID, not full object
  case settings
}
```

---

## 6. Async Operations in Models

### Loading State

```swift
@Observable
class HomeModel {
  var items: [Item] = []
  var isLoading = false
  var error: Error?

  func loadItems() async {
    isLoading = true
    error = nil
    do {
      items = try await apiClient.fetchItems()
    } catch {
      self.error = error
    }
    isLoading = false
  }
}
```

### Task Management

```swift
struct HomeView: View {
  let model: HomeModel

  var body: some View {
    List(model.items) { ... }
      .task {
        await model.loadItems()
      }
  }
}
```

---

## 7. Testing Models

### Unit Testing

```swift
@Test
func testShowDetail() {
  let model = HomeModel()
  #expect(model.detailModel == nil)

  model.showDetail(item: Item(name: "Test"))

  #expect(model.detailModel != nil)
  #expect(model.detailModel?.item.name == "Test")
}

@Test
func testDismissDetail() {
  let model = HomeModel()
  model.showDetail(item: Item(name: "Test"))

  model.dismissDetail()

  #expect(model.detailModel == nil)
}
```

### Testing with Mock Dependencies

```swift
@Test
func testLoadItems() async {
  let mockAPI = MockAPIClient()
  mockAPI.itemsToReturn = [Item(name: "Item 1")]

  let model = HomeModel(apiClient: mockAPI)

  await model.loadItems()

  #expect(model.items.count == 1)
  #expect(model.items[0].name == "Item 1")
}
```

---

## Summary Checklist

- [ ] Models own navigation state (child models as optionals)
- [ ] Views receive Models, never create them
- [ ] Use `@Bindable` for two-way bindings
- [ ] Use `@State` only for ephemeral UI state
- [ ] Models conform to `Identifiable` when used with sheets
- [ ] Dependencies injected via initializers
- [ ] Async operations managed within Models
- [ ] Test Models independently from Views
