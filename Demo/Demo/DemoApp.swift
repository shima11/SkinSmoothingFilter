//
//  DemoApp.swift
//  Demo
//
//  Created by Jinsei Shima on 2024/02/16.
//

import SwiftUI

@main
struct DemoApp: App {
  var body: some Scene {
    WindowGroup {
      if #available(iOS 16.0, *) {
        ContentView()
      } else {
        Text("WIP")
      }
    }
  }
}
