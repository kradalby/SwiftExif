//
//  Extensions.swift
//  SwiftExif
//
//  Created by Kristoffer Dalby on 05/07/2020.
//

import ExifFormat
import Foundation
import exif

let EXIFIFDCOUNT = 5

extension ExifData {
  static func new(imagePath: String) -> ExifData? {
    let rawUnsafeExifData = exif_data_new_from_file(imagePath)

    if let rawExifData = rawUnsafeExifData {
      return rawExifData.pointee
    }

    return nil
  }

  static func new(_ data: Data) -> ExifData? {
    data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
      let rawUnsafeExifData = exif_data_new_from_data(bytes, UInt32(data.count))

      if let rawExifData = rawUnsafeExifData {
        return rawExifData.pointee
      }

      return nil
    }
  }

  mutating func content() -> [ExifContent] {

    let contents = withUnsafePointer(
      to: &self.ifd.0
    ) {
      Array(
        UnsafeBufferPointer(
          start: $0, count: EXIFIFDCOUNT
        ))
    }

    return contents.compactMap({ $0?.pointee })
  }

  mutating func toDict() -> [String: [String: String]] {
    let ifds = ["0", "1", "EXIF", "GPS", "Interoperability"]
    return Dictionary(
      uniqueKeysWithValues:
        zip(ifds, self.content()).map({ ($0, $1.toDict()) }))
  }

  mutating func toRawDict() -> [String: [String: String]] {
    let ifds = ["0", "1", "EXIF", "GPS", "Interoperability"]
    return Dictionary(
      uniqueKeysWithValues:
        zip(ifds, self.content()).map({ ($0, $1.toRawDict()) }))
  }

  mutating func toValueAndRawValueDict() -> [String: [String: (String, String)]] {
    let ifds = ["0", "1", "EXIF", "GPS", "Interoperability"]
    return Dictionary(
      uniqueKeysWithValues:
        zip(ifds, self.content()).map({ ($0, $1.toValueAndRawValueDict()) }))
  }
}

extension ExifContent {
  // mutating func ifdName() -> String? {
  //   let ifd = withUnsafeMutablePointer(
  //     to: &self
  //   ) { exif_content_get_ifd($0) }

  //   if let ifdName = exif_ifd_get_name(ifd) {
  //     let str = String(cString: ifdName)
  //     return str
  //   }

  //   return nil
  // }

  func entries() -> [ExifEntry] {
    if let rawEntries = self.entries {
      let entries = Array(
        UnsafeBufferPointer(
          start: rawEntries,
          count: Int(self.count)
        )
      )

      return entries.compactMap({ $0?.pointee })
    }

    return []
  }

  func toDict() -> [String: String] {
    var entries = [(String, String)]()
    for var entry in self.entries() {
      if let tuple = entry.toTuple() {
        entries.append(tuple)
      }
    }

    return Dictionary(uniqueKeysWithValues: entries)
  }

  func toRawDict() -> [String: String] {
    var entries = [(String, String)]()
    for var entry in self.entries() {
      if let tuple = entry.toRawTuple() {
        entries.append(tuple)
      }
    }

    return Dictionary(uniqueKeysWithValues: entries)
  }

  func toValueAndRawValueDict() -> [String: (String, String)] {
    var entries = [(String, (String, String))]()
    for var entry in self.entries() {
      if let tuple = entry.toTupleWithRaw() {
        entries.append(tuple)
      }
    }

    return Dictionary(uniqueKeysWithValues: entries)
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
    let trimmedValue = str.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedValue
  }

  mutating func rawValue() -> String? {
    let value = UnsafeMutablePointer<Int8>.allocate(capacity: 256)
    exif_entry_format_value(
      &self,
      value,
      256
    )

    let str = String(cString: value)
    let trimmedValue = str.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedValue
  }

  mutating func toTuple() -> (String, String)? {
    if let key = self.key() {
      let value = self.value()

      return (key, value)
    }
    return nil
  }

  mutating func toRawTuple() -> (String, String)? {
    if let key = self.key(), let value = self.rawValue() {
      return (key, value)
    }
    return nil
  }

  mutating func toTupleWithRaw() -> (String, (String, String))? {
    if let key = self.key(), let rawValue = self.rawValue() {
      let value = self.value()

      return (key, (value: value, raw: rawValue))
    }
    return nil
  }
}

extension ExifTag {
  func name() -> String? {
    if let value = exif_tag_get_name(self) {
      let str = String(cString: value)
      return str
    }

    return nil
  }

  func title() -> String? {
    if let value = exif_tag_get_title(self) {
      let str = String(cString: value)
      return str
    }

    return nil
  }

  func description() -> String? {
    if let value = exif_tag_get_description(self) {
      let str = String(cString: value)
      return str
    }

    return nil
  }

}

extension ExifFormat {
  func name() -> String? {
    if let value = exif_format_get_name(self) {
      let str = String(cString: value)
      return str
    }
    return nil
  }
}
