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

    let rawUnsafeExifData = exif_data_new_from_file(imagePath.absoluteString)
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
            self.data["undefined"]?.merging(ifdDict) { (current, _) in current }
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

extension ExifData {
  mutating func content() -> [UnsafeMutablePointer<ExifContent>?] {
    let contents = Array(
      UnsafeBufferPointer(
        start: &self.ifd.0,
        count: EXIFIFDCOUNT
      )
    )

    return contents

  }

}

extension ExifContent {
  mutating func ifdName() -> String? {
    let ifd = exif_content_get_ifd(&self)

    if let ifdName = exif_ifd_get_name(ifd) {
      let str = String(cString: ifdName)
      return str
    }

    return nil
  }

  func entries() -> [UnsafeMutablePointer<ExifEntry>?] {
    if let rawEntries = self.entries {
      let entries = Array(
        UnsafeBufferPointer(
          start: rawEntries,
          count: Int(self.count)
        )
      )

      return entries
    }

    return []
  }
}

extension ExifEntry {
  func key() -> String? {

    let ifd = exif_content_get_ifd(self.parent)

    if let name = exif_tag_get_title_in_ifd(self.tag, ifd) {
      let str = String(cString: name)
      print(str)
      return str
    }

    return nil
  }

  mutating func value() -> String {

    let value = UnsafeMutablePointer<Int8>.allocate(capacity: 256)
    exif_entry_get_value(
      &self,
      value,
      256
    )

    let str = String(cString: value)
    return str
  }

}
