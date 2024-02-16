// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SkinSmoothingFilter",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(
      name: "SkinSmoothingFilter",
      targets: ["SkinSmoothingFilter"]),
  ],
  targets: [
    .target(
      name: "SkinSmoothingFilter"
    ),
    .testTarget(
      name: "SkinSmoothingFilterTests",
      dependencies: ["SkinSmoothingFilter"]),
  ]
)
