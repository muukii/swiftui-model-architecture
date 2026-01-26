# Model-Driven Architecture with Observation Framework

A SwiftUI architecture exploration project based on the principle: **"Model's Existence = Screen's Existence"**

## Core Concept

- If a Model exists (is not nil), the corresponding screen is displayed
- Parent Models create child Models (lazy instantiation)
- Views receive Models, never create them
- Uses Swift's Observation framework (`@Observable`)

## Project Structure

```
ModelArchitecture/
├── Documentation/
│   ├── PRINCIPLES.md    # Design principles
│   └── PRACTICES.md     # Concrete patterns
├── ModelArchitecture/
│   ├── Models/
│   │   ├── AppModel.swift
│   │   ├── HomeModel.swift
│   │   ├── DetailModel.swift
│   │   └── Item.swift
│   ├── Views/
│   │   ├── RootView.swift
│   │   ├── HomeView.swift
│   │   └── DetailView.swift
│   └── ModelArchitectureApp.swift
└── Maestro/
    └── flows/           # UI tests
```

## Quick Start

```bash
# Build
xcodebuild -scheme ModelArchitecture -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run Maestro UI tests
maestro test Maestro/flows/
```

## Key Patterns

### Sheet Navigation

```swift
@Observable
class HomeModel {
  var detailModel: DetailModel?  // nil = sheet hidden

  func showDetail(item: Item) {
    detailModel = DetailModel(item: item)
  }
}

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

## Exploration Points

- [x] `@Observable` + `@Bindable` combination
- [ ] NavigationStack path Model management
- [ ] Deep nesting Model references
- [ ] Model unit tests

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
