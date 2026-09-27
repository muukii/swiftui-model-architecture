# UIModel Routing Architecture for SwiftUI

This repository is a small SwiftUI prototype for representing app-level routing as an explicit **UIModel tree**.

The demo uses a fictional community app with authentication, initial setup, four retained tabs, deep links, app-wide presentations, and restricted states. Names and sample content are deliberately generic so the architecture can be discussed publicly without depending on a real product.

## The idea

Navigation is larger than a single `NavigationPath`. A production-shaped app may have all of these at once:

- a session boundary such as signed out or signed in;
- a setup or preparation gate before the main UI is ready;
- several tab roots that remain alive while another tab is visible;
- an independent navigation stack in each tab;
- app-wide sheets and blocking layers;
- external requests that arrive before their destination can be shown.

The prototype models that shape explicitly:

```text
external URL or app event
          |
          v
       UIIntent                 one-shot request
          |
          v
      AppUIModel                persistent UI state
      |-- session
      |   |-- signedOut
      |   `-- signedIn
      |       |-- setup
      |       `-- main
      |           |-- preparing
      |           |-- tabs
      |           `-- restricted
      |-- pendingIntent?
      |-- sheet?
      `-- blockingNotice?
```

SwiftUI then projects this state into views.

## Why `UIModel`?

`ViewModel` often suggests one helper object per view. Here, the object has a different responsibility: it describes the intended UI topology, owns the lifetimes of child UI scopes, and handles transitions between them. `UIModel` makes that role explicit while leaving domain models independent of the UI.

The central rule is slightly more precise than “model existence equals screen visibility”:

> A UIModel's existence means that its UI scope is retained. Selection and presentation state determine whether that scope is currently visible.

That distinction matters for tabs. All four tab UIModels can continue to exist while only one tab is selected, preserving each tab's navigation stack.

## `UIIntent` and `UIModel` are different

A `UIIntent` is a one-shot request:

```swift
enum UIIntent {
  case openStory(id: String)
  case showActivity(filter: ActivityFilter)
  case openConversation(id: String)
  case openPreferences
  case showAnnouncement
}
```

The UIModel tree is the durable result after that request is interpreted. For example, `openConversation` selects the Messages tab and installs a conversation UIModel in that tab's canonical navigation path. The intent does not remain the source of truth after routing finishes.

If the app is not ready, the root stores the intent as `pendingIntent`. Authentication, setup, and preparation continue normally; the intent is replayed when the tab container is available.

```text
deep link
   |
   v
UIIntent ---- app not ready ----> pendingIntent
   |                                  |
   | app ready                        | readiness changes
   v                                  v
mutate the UIModel tree <-------------+
```

## Demo topology

The sample exercises the following states:

```text
AppUIModel
|-- session
|   |-- signedOut(SignInUIModel)
|   `-- signedIn(SignedInUIModel)
|       |-- setup(ProfileSetupUIModel)
|       `-- main(MainUIModel)
|           |-- preparing
|           |-- tabs(TabContainerUIModel)
|           |   |-- HomeUIModel
|           |   |-- ActivityUIModel
|           |   |-- MessagesUIModel
|           |   `-- AccountUIModel
|           `-- restricted
|-- sheet?
|-- blockingNotice?
`-- pendingIntent?
```

The four tab UIModels are retained together. Each owns its own typed path, so switching tabs does not destroy another tab's navigation history. App-level presentation state lives above the tabs because it is not part of any one stack.

## What remains local to a view

The architecture does not move every piece of screen state into the UIModel tree.

Use a UIModel when state must outlive a particular view instance, participate in routing, or be controlled externally. Keep ephemeral interaction state in a stateful SwiftUI host.

| State | Owner |
|---|---|
| session, selected tab, paths, presentations | UIModel tree |
| pending external route | root UIModel |
| fetched content needed after view recreation | feature UIModel |
| text-field focus, draft interaction, animation phase | stateful host view |
| value rendering and action closures | state view |

Conceptually:

```text
External State
`-- Stateful View
    `-- State View
```

This keeps the externally controllable shape explicit without turning transient SwiftUI mechanics into global state.

## Running the prototype

Open `ModelArchitecture.xcodeproj` in Xcode and run the `ModelArchitecture` scheme on an iOS Simulator.

The normal path through the demo is:

1. Tap **Sign In**.
2. Complete the two setup steps with **Continue** and **Finish Setup**.
3. Leave the preparation gate with **Enter App**.
4. Explore the retained **Home**, **Activity**, **Messages**, and **Account** tabs.

The floating **Route Lab** button exposes the same routing entry point used by deep links. It can open destinations, show app-level presentations, enter restricted mode, and display a blocking notice. The lab also makes the current UIModel tree and any pending intent observable while experimenting.

## Deep links

The app registers the `uimodel-demo` URL scheme. These examples can be opened from Terminal while the app is installed in the booted simulator:

```bash
xcrun simctl openurl booted 'uimodel-demo://home'
xcrun simctl openurl booted 'uimodel-demo://home/story/story-1'
xcrun simctl openurl booted 'uimodel-demo://activity/mentions'
xcrun simctl openurl booted 'uimodel-demo://messages/conversation/conversation-1'
xcrun simctl openurl booted 'uimodel-demo://account/preferences'
xcrun simctl openurl booted 'uimodel-demo://announcement/welcome'
```

Try opening a destination URL before signing in. The app should retain it as a pending intent and apply it only after the setup and preparation gates have completed.

## Building from the command line

```bash
xcodebuild \
  -project ModelArchitecture.xcodeproj \
  -scheme ModelArchitecture \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## Maestro flows

The UI flows cover the ordinary session-to-tabs journey and routing from the Route Lab. With the app installed on a simulator:

```bash
maestro test Maestro/flows/
```

The flows use visible labels for user journeys and the `route-lab-button` accessibility identifier for the developer entry point.

## Design boundaries

This project is intentionally a routing prototype, not a complete application architecture.

- Domain entities and persistence are sample-only.
- `UIIntent` is an input vocabulary, not a second state store.
- A path is appropriate for an ordered stack, but it is not expected to encode the entire app.
- App-wide sheets and blocking UI are modeled separately from per-tab stacks.
- The example favors explicit transitions and inspectable state over framework abstraction.

## Requirements

- Xcode with Swift Observation support
- iOS 17 or later
- Maestro only when running the optional UI flows
