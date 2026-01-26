# Design Principles

## Model-Driven Architecture with Observation Framework

### Core Concept: Model's Existence = Screen's Existence

This architecture is built on a fundamental principle: **the existence of a Model object directly corresponds to the existence of a screen (or UI component)**.

---

## 1. Problems with Traditional Approaches

### View Creates ViewModel

In many MVVM implementations, Views are responsible for creating their ViewModels:

```swift
struct HomeView: View {
  @State var viewModel = HomeViewModel()  // View creates ViewModel

  var body: some View {
    // ...
  }
}
```

**Issues:**

- **Lifecycle ambiguity**: When is `HomeViewModel` actually initialized? Is it when `HomeView` struct is created, or when it appears on screen?
- **Multiple instantiation**: SwiftUI may recreate `HomeView` struct multiple times, but `@State` prevents multiple `HomeViewModel` instances. This implicit behavior is confusing.
- **Testing difficulty**: The View controls ViewModel creation, making it hard to inject mock dependencies.
- **Navigation coupling**: The View must know how to create ViewModels for child screens.

### @State var viewModel Ambiguity

```swift
@State var viewModel = HomeViewModel()
```

This pattern has unclear semantics:
- `@State` is designed for value types, but `HomeViewModel` is typically a reference type
- The initialization timing is unclear
- Ownership and lifecycle are implicit

---

## 2. Core Principle: Model's Existence = Screen's Existence

### The Rule

> If a Model exists (is not nil), the corresponding screen should be displayed.
> If a Model is nil, the corresponding screen should be hidden.

### Implementation

```swift
@Observable
class HomeModel {
  var detailModel: DetailModel?  // nil = no detail screen

  func showDetail(item: Item) {
    detailModel = DetailModel(item: item)  // Creates screen
  }

  func dismissDetail() {
    detailModel = nil  // Destroys screen
  }
}
```

```swift
struct HomeView: View {
  @Bindable var model: HomeModel

  var body: some View {
    // ...
    .sheet(item: $model.detailModel) { detail in
      DetailView(model: detail)
    }
  }
}
```

### Benefits

1. **Explicit lifecycle**: Model creation = screen creation
2. **Clear ownership**: Parent Model owns child Models
3. **Predictable state**: UI state is directly visible in Model graph
4. **Easy testing**: Create Model instances directly in tests
5. **Type safety**: Swift's optional types enforce screen existence rules

---

## 3. Why Observation Framework?

### @Observable Advantages

Swift's Observation framework (iOS 17+) provides:

- **Simple syntax**: Just `@Observable` macro, no Combine publishers
- **Automatic tracking**: SwiftUI automatically tracks which properties are read
- **Fine-grained updates**: Only Views reading changed properties re-render
- **Reference semantics**: Works naturally with class-based Models

### Comparison with Combine

| Aspect | Observation | Combine |
|--------|-------------|---------|
| Syntax | `@Observable` | `ObservableObject` + `@Published` |
| Boilerplate | Minimal | More verbose |
| Update granularity | Property-level | Object-level |
| Learning curve | Lower | Higher |

### @Bindable for Two-way Binding

```swift
struct HomeView: View {
  @Bindable var model: HomeModel  // Enables $model.property bindings

  var body: some View {
    TextField("Name", text: $model.name)  // Two-way binding
  }
}
```

---

## 4. Model Graph

### Tree Structure

Models form a tree structure starting from a root:

```
AppModel (root)
├── HomeModel
│   └── DetailModel?
├── SettingsModel?
└── ProfileModel
    └── EditProfileModel?
```

### Parent Owns Children

- Parent Model creates child Models (lazy instantiation)
- Parent Model destroys child Models (set to nil)
- Child Models never create sibling or parent Models

### Navigation State as Model Properties

```swift
@Observable
class AppModel {
  var navigationPath: [NavigationDestination] = []
  var currentTab: Tab = .home
  var homeModel: HomeModel
  var settingsModel: SettingsModel?  // Lazy
}
```

### Benefits of Model Graph

1. **Centralized state**: Entire app state is in one tree
2. **Debuggable**: Print Model graph to see app state
3. **Serializable**: Save/restore navigation state
4. **Testable**: Create specific Model configurations for tests

---

## Summary

| Traditional | Model-Driven |
|-------------|--------------|
| View creates ViewModel | Parent Model creates child Model |
| Implicit lifecycle | Explicit lifecycle (Model existence) |
| Navigation in Views | Navigation in Models |
| Scattered state | Centralized Model graph |
| Combine complexity | Observation simplicity |

The key insight is: **treat Models as the source of truth for what should be on screen**. Views simply reflect the Model graph state.
