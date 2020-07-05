// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftExif",
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "SwiftExif",
      targets: ["SwiftExif"]
    )
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    // .package(path: "../CSwiftExif")
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .systemLibrary(
      name: "exif",
      pkgConfig: "libexif",
      providers: [
        .apt(["libexif-dev"]),
        .brew(["libexif"]),
      ]
    ),
    .systemLibrary(
      name: "iptc",
      pkgConfig: "libiptcdata",
      providers: [
        .apt(["libiptcdata"]),
        .brew(["libiptcdata"]),
      ]
    ),
    .target(
      name: "SwiftExif",
      dependencies: ["exif"]
    ),
    .testTarget(
      name: "SwiftExifTests",
      dependencies: ["SwiftExif"]
    ),
  ]
)
