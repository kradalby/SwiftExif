import Foundation
import exif

#if os(Linux)
  import Glibc
#else
  import Darwin
#endif

let EXIFIFDCOUNT = 5

public struct Image {
  private var data: [String: [String: String]]

  public init(imagePath: URL) {
    self.data = ["undefined": [:]]

    let rawUnsafeExifData = exif_data_new_from_file(imagePath.path)
    defer {
      exif_data_free(
        rawUnsafeExifData
      )
    }

    if let rawExifData = rawUnsafeExifData {
      let contents = rawExifData.pointee.content()

      for unsafeContent in contents {
        if let content = unsafeContent {
          var ifdDict: [String: String] = [:]

          let entries = content.pointee.entries()
          for unsafeEntry in entries {
            if let entry = unsafeEntry {
              let value = entry.pointee.value()
              if let key = entry.pointee.key() {
                ifdDict[key] = value
              }
            }
          }

          if let ifdName = content.pointee.ifdName() {
            self.data[ifdName] = ifdDict
          } else {
            self.data["undefined"] = self.data["undefined"]?.merging(ifdDict) { (current, _) in
              current
            }
          }
        }
      }
    }
  }

  public func getData() -> [String: [String: String]] {
    let copy = self.data
    return copy
  }
}
