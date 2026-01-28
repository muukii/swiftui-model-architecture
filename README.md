# Model-Driven Architecture for SwiftUI

A SwiftUI architecture built on the principle: **"Model's Existence = Screen's Existence"**

Using Swift's Observation framework (`@Observable`, `@Bindable`) to create explicit, testable, and predictable UI state management.

---

## Table of Contents

- [Core Concept](#core-concept)
- [Getting Started](#getting-started)
- [What is "Model"?](#what-is-model)
- [Model Graph](#model-graph)
- [Patterns](#patterns)
  - [Sheet Navigation](#1-sheet-navigation)
  - [Confirmation Dialog](#2-confirmation-dialog)
  - [NavigationStack](#3-navigationstack)
  - [Model-per-Screen](#4-model-per-screen)
  - [TabView](#5-tabview)
  - [Async Operations](#6-async-operations)
  - [Dependency Injection](#7-dependency-injection)
- [Local State (@State) Guidelines](#local-state-state-guidelines)
- [Demo App](#demo-app)
- [Requirements](#requirements)

---

## Core Concept

### The Rule

> If a Model exists (is not nil), the corresponding screen should be displayed.
> If a Model is nil, the corresponding screen should be hidden.

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

### The Inversion

```
Traditional SwiftUI:
  View creates ViewModel → View controls navigation → State scattered

Model-Driven Architecture:
  Model Graph defines state → Views reflect state → Single source of truth
```

### Benefits

| Benefit | Description |
|---------|-------------|
| **Explicit Lifecycle** | Model creation = screen creation. No ambiguity. |
| **Testable** | Unit test navigation and business rules without UI |
| **Predictable** | Any screen state can be inspected and reproduced |
| **SwiftUI Native** | Built on `@Observable`, `@Bindable`, standard APIs |

---

## Getting Started

Align the root of your Model Graph with the root of your View hierarchy.

### Step 1: Define the Model Graph Root

```swift
@Observable
class AppModel {
  // Your app's state starts here
}
```

### Step 2: Create and Hold at App Entry Point

```swift
@main
struct MyApp: App {
  @State private var appModel = AppModel()

  var body: some Scene {
    WindowGroup {
      RootView(model: appModel)
    }
  }
}
```

### Step 3: Receive in Root View

```swift
struct RootView: View {
  let model: AppModel

  var body: some View {
    // Build View tree from Model Graph
  }
}
```

### The Connection Point

```
App (Entry Point)
    │
    ├── @State appModel ← Model Graph root
    │
    └── WindowGroup
            └── RootView(model: appModel) ← Connection
                    │
                    └── View Tree
```

---

## What is "Model"?

### The Overloaded Term

"Model" appears in many contexts:

| Context | Meaning |
|---------|---------|
| MVC | Domain data and business logic |
| Core Data | Data schema (NSManagedObjectModel) |
| CALayer | Target state (vs presentation layer) |
| **This Architecture** | **UI state structure** |

### The Common Essence

> **Model = Source of Truth**

CALayer illustrates this well:

```swift
layer.position = CGPoint(x: 100, y: 100)  // model layer (target)
layer.presentation()?.position             // presentation layer (current)
```

In this architecture:

```
CALayer:        model layer    →  presentation layer
This arch:      UI Model       →  SwiftUI View
Concept:        intended state →  rendered state
```

**Model is what should be. View is what you see.**

### UI Model vs Domain Model

```
┌─────────────────────────────────────────┐
│  Domain Model                            │
│  - User, Order, Product                 │
│  - Business rules                       │
│  - Independent of UI                    │
└─────────────────────────────────────────┘
                ↓ referenced by
┌─────────────────────────────────────────┐
│  UI Model (= "Model" here)              │
│  - SheetsTabModel, NavigationTabModel   │
│  - UI state (what screens are shown)    │
│  - Screen-specific data and actions     │
└─────────────────────────────────────────┘
                ↓ projected to
┌─────────────────────────────────────────┐
│  SwiftUI View                            │
│  - Renders based on UI Model state      │
└─────────────────────────────────────────┘
```

---

## Model Graph

### Why "Graph" not "Tree"?

- **Ownership** follows a tree structure (parent owns children)
- **References** can go any direction (callbacks, delegates)
- Including references, it's a **graph**

### Structure

```
AppModel (root)
├── selectedTab: Tab
├── sheetsTabModel
│   ├── items: [Item]
│   ├── detailModel?          ← "Detail screen can exist here"
│   └── deleteConfirmation?   ← "Dialog can exist here"
└── navigationTabModel
    ├── path: [Destination]
    └── itemDetailModels: [ID: Model]  ← Cached Models
```

The **structure** defines what's possible. The **values** define current state.

### State Space

```
Model Graph ≠ "What is currently displayed"
Model Graph = "The shape of possible states"
```

---

## Patterns

### 1. Sheet Navigation

Model's optional property controls sheet presentation:

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
    Button("Show") { model.showChild() }
      .sheet(item: $model.childModel) { child in
        ChildView(model: child)
      }
  }
}
```

### 2. Confirmation Dialog

Optional property controls dialog visibility and carries associated data:

```swift
@Observable
class HomeModel {
  var deleteConfirmation: Item?  // nil = no dialog

  func requestDelete(_ item: Item) {
    deleteConfirmation = item
  }

  func executeDelete() {
    guard let item = deleteConfirmation else { return }
    items.removeAll { $0.id == item.id }
    deleteConfirmation = nil
  }
}

struct HomeView: View {
  @Bindable var model: HomeModel

  var body: some View {
    List { ... }
      .confirmationDialog(
        "Delete Item",
        isPresented: Binding(
          get: { model.deleteConfirmation != nil },
          set: { if !$0 { model.deleteConfirmation = nil } }
        ),
        presenting: model.deleteConfirmation
      ) { item in
        Button("Delete \(item.name)", role: .destructive) {
          model.executeDelete()
        }
      }
  }
}
```

### 3. NavigationStack

Path array controls navigation stack:

```swift
@Observable
class NavigationModel {
  enum Destination: Hashable {
    case detail(Item)
    case settings
  }

  var path: [Destination] = []

  func push(_ dest: Destination) {
    path.append(dest)
  }

  func popToRoot() {
    path.removeAll()
  }
}

struct ContentView: View {
  @Bindable var model: NavigationModel

  var body: some View {
    NavigationStack(path: $model.path) {
      ListView()
        .navigationDestination(for: NavigationModel.Destination.self) { dest in
          switch dest {
          case .detail(let item): DetailView(item: item)
          case .settings: SettingsView()
          }
        }
    }
  }
}
```

### 4. Model-per-Screen

Cache Models for screens that need their own state:

```swift
@Observable
class AppModel {
  var path: [Destination] = []
  private var detailModels: [Item.ID: DetailModel] = [:]

  func detailModel(for item: Item) -> DetailModel {
    if let existing = detailModels[item.id] {
      return existing
    }
    let model = DetailModel(item: item)
    detailModels[item.id] = model
    return model
  }

  // Clean up when navigating away
  private func cleanupUnusedModels() {
    let activeIDs = Set(path.compactMap { dest -> Item.ID? in
      if case .detail(let item) = dest { return item.id }
      return nil
    })
    detailModels = detailModels.filter { activeIDs.contains($0.key) }
  }
}
```

### 5. TabView

Lazy initialization for tab Models:

```swift
@Observable
class AppModel {
  enum Tab { case home, search, profile }
  var selectedTab: Tab = .home

  private var _homeModel: HomeModel?
  private var _searchModel: SearchModel?

  var homeModel: HomeModel {
    if _homeModel == nil { _homeModel = HomeModel() }
    return _homeModel!
  }

  var searchModel: SearchModel {
    if _searchModel == nil { _searchModel = SearchModel() }
    return _searchModel!
  }
}

struct RootView: View {
  @Bindable var model: AppModel

  var body: some View {
    TabView(selection: $model.selectedTab) {
      HomeView(model: model.homeModel)
        .tag(AppModel.Tab.home)
      SearchView(model: model.searchModel)
        .tag(AppModel.Tab.search)
    }
  }
}
```

### 6. Async Operations

Loading state and error handling in Model:

```swift
@Observable
class DataModel {
  var items: [Item] = []
  var isLoading = false
  var errorAlert: ErrorInfo?

  struct ErrorInfo: Identifiable {
    let id = UUID()
    let message: String
  }

  @MainActor
  func loadItems() async {
    isLoading = true
    defer { isLoading = false }

    do {
      items = try await api.fetchItems()
    } catch {
      errorAlert = ErrorInfo(message: error.localizedDescription)
    }
  }
}
```

### 7. Dependency Injection

Inject dependencies via initializer:

```swift
protocol Storage {
  var theme: Theme { get set }
}

@Observable
class SettingsModel {
  private let storage: Storage

  var theme: Theme

  init(storage: Storage) {
    self.storage = storage
    self.theme = storage.theme
  }

  func save() {
    var s = storage
    s.theme = theme
  }
}

// Production
let model = SettingsModel(storage: UserDefaultsStorage())

// Testing
let model = SettingsModel(storage: MockStorage())
```

---

## Local State (@State) Guidelines

### When to Use @State

Use for **ephemeral UI state** that doesn't affect business logic:

```swift
struct FormView: View {
  let model: FormModel

  @State private var isAnimating = false      // Animation
  @State private var showTooltip = false      // Temporary UI
  @FocusState private var focusedField: Field? // Focus
}
```

### When NOT to Use @State

Do NOT use for:
- Business data → Model
- Navigation state → Model
- Shared state → Model
- State that survives view recreation → Model

```swift
// BAD
struct HomeView: View {
  @State var items: [Item] = []  // Should be in Model
}

// GOOD
struct HomeView: View {
  let model: HomeModel  // Model owns items
}
```

### Escaping vs Local State

| Scenario | Use |
|----------|-----|
| Shared across screens | Model (Escaping) |
| Survives navigation | Model (Escaping) |
| Ephemeral UI only | `@State` (Local) |

---

## Demo App

The demo app demonstrates all patterns:

```
ModelArchitecture/
├── Models/
│   ├── AppModel.swift           # Root + TabView + Lazy init
│   ├── SheetsTabModel.swift     # Sheet + Confirmation Dialog
│   ├── NavigationTabModel.swift # NavigationStack + Model-per-Screen
│   ├── AsyncTabModel.swift      # Async + Loading + Error
│   └── SettingsTabModel.swift   # Dependency Injection
└── Views/
    ├── RootView.swift           # TabView
    ├── SheetsTabView.swift
    ├── NavigationTabView.swift
    ├── AsyncTabView.swift
    └── SettingsTabView.swift
```

### Run

```bash
# Build
xcodebuild -scheme ModelArchitecture \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run Maestro UI tests
maestro test Maestro/flows/
```

---

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
