import Foundation
import exif
import iptc

#if os(Linux)
  import Glibc
#else
  import Darwin
#endif

public struct Image {
  var exifData: ExifData?
  var iptcData: IptcData?

  public init(imagePath: URL) {
    exifData = ExifData.new(imagePath: imagePath.path)
    iptcData = IptcData.new(imagePath: imagePath.path)
  }

  public func Exif() -> [String: [String: String]] {
    if var data = self.exifData {
      return data.toDict()
    }
    return [:]
  }

  public func ExifRaw() -> [String: [String: String]] {
    if var data = self.exifData {
      return data.toRawDict()
    }
    return [:]
  }

  public func ExifWithRaw() -> [String: [String: (String, String)]] {
    if var data = self.exifData {
      return data.toValueAndRawValueDict()
    }
    return [:]
  }

  public func Iptc() -> [String: Any] {
    if let data = self.iptcData {
      return data.toDict()
    }
    return [:]
  }
}
