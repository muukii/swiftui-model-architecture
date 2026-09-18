//
//  ModelArchitectureApp.swift
//  ModelArchitecture
//
//  Created by Hiroshi Kimura on 2026/01/26.
//

import SwiftUI

@main
struct ModelArchitectureApp: App {
  /// The single root UIModel retained for the lifetime of this scene.
  @State private var uiModel = AppUIModel()

  var body: some Scene {
    WindowGroup {
      AppRootView(uiModel: uiModel)
        .onOpenURL { url in
          uiModel.handle(url: url)
        }
    }
  }
}
