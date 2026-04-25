import Foundation

/// EXIF + IPTC extracted from a single source. Sendable, so the result
/// can cross task boundaries without the consumer needing a wrapper.
public struct ExifResult: Sendable, Equatable {
  /// Human-readable EXIF values, keyed `[ifd][tag]`. The five IFDs libexif
  /// surfaces are `"0"`, `"1"`, `"EXIF"`, `"GPS"`, and `"Interoperability"`.
  /// Empty when the source carries no EXIF block.
  public let exif: [String: [String: String]]

  /// Raw EXIF values, same shape as ``exif``. Strings represent the
  /// underlying numeric form rather than libexif's localised rendering.
  public let exifRaw: [String: [String: String]]

  /// IPTC fields with the handful of strings Munin reads broken out of
  /// the otherwise-untyped IPTC blob.
  public let iptc: IptcFields

  /// EXIF orientation tag, decoded from the raw IFD0 entry. `nil` when
  /// the source has no EXIF or no Orientation tag.
  public let orientation: Orientation?

  public init(
    exif: [String: [String: String]],
    exifRaw: [String: [String: String]],
    iptc: IptcFields,
    orientation: Orientation?
  ) {
    self.exif = exif
    self.exifRaw = exifRaw
    self.iptc = iptc
    self.orientation = orientation
  }
}

/// IPTC values pulled out of the legacy `[String: Any]` dictionary into
/// typed slots. Field names follow the IPTC tag titles libiptcdata
/// reports.
public struct IptcFields: Sendable, Equatable {
  /// IPTC "Keywords" field, empty when absent.
  public let keywords: [String]

  public let city: String?
  public let provinceState: String?
  public let countryCode: String?
  public let countryName: String?

  /// Every other String-valued IPTC field that didn't get a typed slot.
  /// Pulled in so consumers can still reach values like "Date Created"
  /// or "Copyright Notice" without falling back to the deprecated dict
  /// API.
  public let extras: [String: String]

  public init(
    keywords: [String] = [],
    city: String? = nil,
    provinceState: String? = nil,
    countryCode: String? = nil,
    countryName: String? = nil,
    extras: [String: String] = [:]
  ) {
    self.keywords = keywords
    self.city = city
    self.provinceState = provinceState
    self.countryCode = countryCode
    self.countryName = countryName
    self.extras = extras
  }
}

/// EXIF orientation tag values from the spec.
public enum Orientation: Int, Sendable, CaseIterable {
  case normal = 1
  case flippedHorizontally = 2
  case rotated180 = 3
  case flippedVertically = 4
  case flippedHorizontallyRotated270 = 5
  case rotated90 = 6
  case flippedHorizontallyRotated90 = 7
  case rotated270 = 8
}

public enum ParseError: Error, Sendable, Equatable {
  /// The path didn't resolve to a readable file. The contents of a
  /// readable-but-EXIF-less file is not an error — it produces an
  /// ``ExifResult`` with empty dicts and `nil` orientation.
  case fileUnreadable(URL)
}
