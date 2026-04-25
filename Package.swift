// swift-tools-version:6.3

import PackageDescription

let package = Package(
  name: "SwiftExif",
  products: [
    .library(
      name: "SwiftExif",
      type: .static,
      targets: ["SwiftExif"]
    )
  ],
  targets: [
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
        .apt(["libiptcdata0-dev"]),
        .brew(["libiptcdata"]),
      ]
    ),
    .target(
      name: "ExifFormat",
      dependencies: ["exif", "iptc"],
      path: "Sources/ExifFormat"
    ),
    .target(
      name: "SwiftExif",
      dependencies: ["exif", "ExifFormat", "iptc"]
    ),
    .testTarget(
      name: "SwiftExifTests",
      dependencies: ["SwiftExif"]
    ),
  ],
  cLanguageStandard: .c11
)
