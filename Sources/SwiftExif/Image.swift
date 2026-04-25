import Foundation
import exif
import iptc

public struct Image {
  var exifData: ExifData?
  var iptcData: IptcData?

  @available(*, deprecated, message: "Use Image.parse(at:) for a Sendable typed result.")
  public init(imagePath: URL) {
    exifData = ExifData.new(imagePath: imagePath.path)
    iptcData = IptcData.new(imagePath: imagePath.path)
  }

  @available(*, deprecated, message: "Use Image.parse(at:) and read ExifResult.exif.")
  public func Exif() -> [String: [String: String]] {
    if var data = self.exifData {
      return data.toDict()
    }
    return [:]
  }

  @available(*, deprecated, message: "Use Image.parse(at:) and read ExifResult.exifRaw.")
  public func ExifRaw() -> [String: [String: String]] {
    if var data = self.exifData {
      return data.toRawDict()
    }
    return [:]
  }

  @available(*, deprecated, message: "Use Image.parse(at:) and pair ExifResult.exif with .exifRaw.")
  public func ExifWithRaw() -> [String: [String: (String, String)]] {
    if var data = self.exifData {
      return data.toValueAndRawValueDict()
    }
    return [:]
  }

  @available(*, deprecated, message: "Use Image.parse(at:) and read ExifResult.iptc.")
  public func Iptc() -> [String: Any] {
    if let data = self.iptcData {
      return data.toDict()
    }
    return [:]
  }
}

extension Image {
  /// Read EXIF and IPTC from a file URL.
  ///
  /// Allocates the libexif/libiptcdata structs, copies their content into
  /// Swift values, then frees the native allocations before returning —
  /// the result owns no C memory and can cross task boundaries.
  ///
  /// Throws ``ParseError/fileUnreadable(_:)`` when the path does not
  /// resolve to a readable file. A readable file with no EXIF or IPTC
  /// is not an error: the corresponding fields on ``ExifResult`` come
  /// back empty.
  public static func parse(at url: URL) throws -> ExifResult {
    guard FileManager.default.isReadableFile(atPath: url.path) else {
      throw ParseError.fileUnreadable(url)
    }
    let exif = exif_data_new_from_file(url.path)
    let iptc = iptc_data_new_from_jpeg(url.path)
    return extract(exif: exif, iptc: iptc)
  }

  /// Read EXIF and IPTC from in-memory JPEG bytes. Same lifecycle as
  /// ``parse(at:)``; never throws — invalid bytes produce an empty
  /// ``ExifResult`` rather than an error.
  ///
  /// libiptcdata has no in-memory JPEG parser (`iptc_data_new_from_data`
  /// expects a raw IIM blob, not a full JPEG), so for IPTC the bytes
  /// are round-tripped through a short-lived tempfile.
  public static func parse(data: Data) -> ExifResult {
    let exif = data.withUnsafeBytes(exifFromBytes)
    let iptc = iptcFromJPEGBytes(data)
    return extract(exif: exif, iptc: iptc)
  }
}

private func exifFromBytes(_ buf: UnsafeRawBufferPointer) -> UnsafeMutablePointer<ExifData>? {
  guard let base = buf.baseAddress, buf.count > 0 else { return nil }
  return exif_data_new_from_data(
    base.assumingMemoryBound(to: UInt8.self),
    UInt32(buf.count))
}

private func iptcFromJPEGBytes(_ data: Data) -> UnsafeMutablePointer<IptcData>? {
  guard !data.isEmpty else { return nil }
  let tmp = FileManager.default.temporaryDirectory
    .appendingPathComponent("swiftexif-\(UUID().uuidString).jpg")
  do {
    try data.write(to: tmp, options: .atomic)
  } catch {
    return nil
  }
  defer { try? FileManager.default.removeItem(at: tmp) }
  return iptc_data_new_from_jpeg(tmp.path)
}

private func extract(
  exif: UnsafeMutablePointer<ExifData>?,
  iptc: UnsafeMutablePointer<IptcData>?
) -> ExifResult {
  defer {
    if let exif { exif_data_unref(exif) }
    if let iptc { iptc_data_unref(iptc) }
  }

  var formatted: [String: [String: String]] = [:]
  var raw: [String: [String: String]] = [:]
  if let exif {
    var data = exif.pointee
    let f = data.toDict()
    if !f.values.allSatisfy(\.isEmpty) {
      formatted = f
      raw = data.toRawDict()
    }
  }

  let iptcFields: IptcFields
  if let iptc {
    iptcFields = makeIptcFields(from: iptc.pointee.toDict())
  } else {
    iptcFields = IptcFields()
  }

  return ExifResult(
    exif: formatted,
    exifRaw: raw,
    iptc: iptcFields,
    orientation: orientation(from: raw))
}

private let typedIptcKeys: Set<String> = [
  "Keywords", "City", "Province/State", "Country Code", "Country Name",
]

private func makeIptcFields(from dict: [String: Any]) -> IptcFields {
  var extras: [String: String] = [:]
  for (key, value) in dict where !typedIptcKeys.contains(key) {
    if let str = value as? String {
      extras[key] = str
    }
  }
  return IptcFields(
    keywords: dict["Keywords"] as? [String] ?? [],
    city: dict["City"] as? String,
    provinceState: dict["Province/State"] as? String,
    countryCode: dict["Country Code"] as? String,
    countryName: dict["Country Name"] as? String,
    extras: extras)
}

private func orientation(from raw: [String: [String: String]]) -> Orientation? {
  guard let str = raw["0"]?["Orientation"], let n = Int(str) else { return nil }
  return Orientation(rawValue: n)
}
