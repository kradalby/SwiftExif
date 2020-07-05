//
//  Extensions.swift
//  SwiftExif
//
//  Created by Kristoffer Dalby on 05/07/2020.
//

import Foundation
import exif

extension ExifData {
  mutating func content() -> [UnsafeMutablePointer<ExifContent>?] {

    let contents = withUnsafePointer(
      to: &self.ifd.0
    ) {
      Array(
        UnsafeBufferPointer(
          start: $0, count: EXIFIFDCOUNT
        ))
    }

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
