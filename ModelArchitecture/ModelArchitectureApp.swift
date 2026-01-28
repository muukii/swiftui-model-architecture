//
//  ModelArchitectureApp.swift
//  ModelArchitecture
//
//  Created by Hiroshi Kimura on 2026/01/26.
//

import SwiftUI

@main
struct ModelArchitectureApp: App {
  // Note: Using @State with @Observable class works in iOS 17+ because:
  // 1. @State ensures single instance across view recreations
  // 2. @Observable provides fine-grained observation
  // This is the recommended pattern for root-level app state in SwiftUI.
  @State private var appModel = AppModel()

  var body: some Scene {
    WindowGroup {
      RootView(model: appModel)
    }
  }
}
