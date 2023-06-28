// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "BlueIntent",
  platforms: [.iOS(.v9), .macOS(.v10_10), .tvOS(.v9)],
  products: [
    .library(
      name: "BlueIntent",
      targets: ["BlueIntent"])
  ],
  targets: [
    .target(
      name: "BlueIntent",
      path: "BlueIntent/Classes/Base",
      publicHeadersPath: "include")
  ]
)
