//
//  ModelArchitectureApp.swift
//  ModelArchitecture
//
//  Created by Hiroshi Kimura on 2026/01/26.
//

import SwiftUI

@main
struct ModelArchitectureApp: App {
  @State private var appModel = AppModel()

  var body: some Scene {
    WindowGroup {
      RootView(model: appModel)
    }
  }
}
