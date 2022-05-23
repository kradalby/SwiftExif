import Foundation
import exif
import iptc


public enum Orientation: Int {
  case normal = 1
  case flippedH // flip H to straighten
  case rotated180 // rotate 180 to straighten
  case flippedV // flip V to straighten
  case flippedHRotated270 // flip H and rotate 90 to straighten
  case rotated90 // rotate 270 to straighten
  case flippedHRotated90 // flip H and rotate 270 to straighten
  case rotated270 // rotate 90 to straighten
  case unknown

}


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

extension Image {
  public var orientation: Orientation {

    if let mainImage = self.ExifRaw()["0"],
       let orientationStr = mainImage["Orientation"],
       let orientation = Int(orientationStr)
    {
      return Orientation(rawValue: orientation) ?? .unknown
    } else {
      return .unknown
    }
  }
}
