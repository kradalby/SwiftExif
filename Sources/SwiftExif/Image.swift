import Foundation
import exif
import iptc

public struct Image {
  var exifData: ExifData?
  var iptcData: IptcData?

  public init(imagePath: URL) {
    exifData = ExifData.new(imagePath: imagePath.path)
    iptcData = IptcData.new(imagePath: imagePath.path)
  }

    public init(_ data: Data) {
      exifData = ExifData.new(data)
      iptcData = IptcData.new(data)
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
