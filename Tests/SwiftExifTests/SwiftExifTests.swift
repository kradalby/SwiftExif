import XCTest

@testable import SwiftExif
@testable import exif
@testable import iptc

let testImage = "Tests/test.jpg"

final class SwiftExifTests: XCTestCase {
  func test() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    XCTAssertEqual("test", "test")
  }

  func testExifReadExifData() {
    let rawUnsafeExifData = exif_data_new_from_file(testImage)
    var exifData = ExifData.new(imagePath: testImage)

    XCTAssertNotNil(rawUnsafeExifData)
    XCTAssertNotNil(exifData)

    let contents = rawUnsafeExifData!.pointee.content()
    let contents2 = exifData!.content()

    XCTAssertEqual(contents.count, 5)
    XCTAssertEqual(contents2.count, 5)
  }

  func testExifReadIfd() {
    var exifData = ExifData.new(imagePath: testImage)

    XCTAssertNotNil(exifData)

    let contents = exifData!.content()

    XCTAssertEqual(contents.count, 5)
  }

  func testImageReadData() {
    let image = Image(imagePath: URL(fileURLWithPath: testImage))
    let exifData = image.Exif()
    let iptcData = image.Iptc()

    XCTAssertNotNil(exifData)
    XCTAssertNotNil(iptcData)
    XCTAssertEqual(exifData.count, 5)
    XCTAssertEqual(iptcData.count, 13)

    XCTAssertTrue(exifData.keys.contains("0"))
    XCTAssertTrue(exifData.keys.contains("1"))
    XCTAssertTrue(exifData.keys.contains("EXIF"))
    XCTAssertTrue(exifData.keys.contains("GPS"))
    XCTAssertTrue(exifData.keys.contains("Interoperability"))

    XCTAssertEqual(exifData["0"]?.count, 10)
    XCTAssertEqual(exifData["1"]?.count, 0)
    XCTAssertEqual(exifData["EXIF"]?.count, 31)
    XCTAssertEqual(exifData["GPS"]?.count, 9)
    XCTAssertEqual(exifData["Interoperability"]?.count, 0)

    XCTAssertEqual(exifData["0"]?["Orientation"], "Top-left")
    XCTAssertEqual(exifData["0"]?["Artist"], "Photographer: Kristoffer Andreas Dalby")
    XCTAssertEqual(
      exifData["0"]?["Copyright"],
      "Copyright: Kristoffer Andreas Dalby (Photographer) - [None] (Editor)")
    XCTAssertEqual(exifData["0"]?["Y-Resolution"], "72")
    XCTAssertEqual(exifData["0"]?["Manufacturer"], "Canon")
    XCTAssertEqual(exifData["0"]?["Model"], "Canon EOS 5D Mark II")
    XCTAssertEqual(exifData["0"]?["Date and Time"], "2018:03:10 13:36:56")
    XCTAssertEqual(exifData["0"]?["X-Resolution"], "72")
    XCTAssertEqual(exifData["0"]?["Software"], "Photos 4.0")
    XCTAssertEqual(exifData["0"]?["Resolution Unit"], "Inch")

    XCTAssertEqual(exifData["EXIF"]?["Camera Owner Name"], "Kristoffer Andreas Dalby")
    XCTAssertEqual(exifData["EXIF"]?["Body Serial Number"], "2431423523")
    XCTAssertEqual(exifData["EXIF"]?["Shutter Speed"], "7.32 EV (1/160 sec.)")
    XCTAssertEqual(exifData["EXIF"]?["Metering Mode"], "Pattern")
    XCTAssertEqual(exifData["EXIF"]?["White Balance"], "Auto white balance")
    XCTAssertEqual(exifData["EXIF"]?["FlashPixVersion"], "FlashPix Version 1.0")
    XCTAssertEqual(exifData["EXIF"]?["Color Space"], "sRGB")
    XCTAssertEqual(exifData["EXIF"]?["Exif Version"], "Exif Version 2.3")
    XCTAssertEqual(exifData["EXIF"]?["Scene Capture Type"], "Standard")
    XCTAssertEqual(exifData["EXIF"]?["Custom Rendered"], "Normal process")
    XCTAssertEqual(exifData["EXIF"]?["Sub-second Time (Digitized)"], "14")
    XCTAssertEqual(exifData["EXIF"]?["Focal Plane Y-Resolution"], "3908.142")
    XCTAssertEqual(exifData["EXIF"]?["Exposure Bias"], "0.00 EV")
    XCTAssertEqual(exifData["EXIF"]?["Pixel X Dimension"], "1280")
    XCTAssertEqual(exifData["EXIF"]?["Focal Plane X-Resolution"], "3849.212")
    XCTAssertEqual(exifData["EXIF"]?["Focal Plane Resolution Unit"], "Inch")
    XCTAssertEqual(exifData["EXIF"]?["Date and Time (Digitized)"], "2018:03:10 13:36:56")
    XCTAssertEqual(exifData["EXIF"]?["Lens Model"], "EF24-105mm f/4L IS USM")
    XCTAssertEqual(exifData["EXIF"]?["Date and Time (Original)"], "2018:03:10 13:36:56")
    XCTAssertEqual(exifData["EXIF"]?["Exposure Mode"], "Manual exposure")
    XCTAssertEqual(exifData["EXIF"]?["Pixel Y Dimension"], "853")
    XCTAssertEqual(exifData["EXIF"]?["Exposure Time"], "1/160 sec.")
    XCTAssertEqual(exifData["EXIF"]?["Flash"], "Flash did not fire, compulsory flash mode")
    XCTAssertEqual(exifData["EXIF"]?["ISO Speed Ratings"], "400")
    XCTAssertEqual(exifData["EXIF"]?["Sub-second Time (Original)"], "14")
    XCTAssertEqual(exifData["EXIF"]?["Maximum Aperture Value"], "4.00 EV (f/4.0)")
    XCTAssertEqual(exifData["EXIF"]?["Exposure Program"], "Manual")
    XCTAssertEqual(exifData["EXIF"]?["Focal Length"], "70.0 mm")
    XCTAssertEqual(exifData["EXIF"]?["Lens Specification"], "24, 105,  0,  0")
    XCTAssertEqual(exifData["EXIF"]?["Aperture"], "4.00 EV (f/4.0)")
    XCTAssertEqual(exifData["EXIF"]?["F-Number"], "f/4.0")

    XCTAssertEqual(exifData["GPS"]?["Altitude"], " 0")
    XCTAssertEqual(exifData["GPS"]?["North or South Latitude"], "N")
    XCTAssertEqual(exifData["GPS"]?["East or West Longitude"], "E")
    XCTAssertEqual(exifData["GPS"]?["Longitude"], " 4, 37, 41.88")
    XCTAssertEqual(exifData["GPS"]?["Latitude"], "52, 24, 18.89")
    XCTAssertEqual(exifData["GPS"]?["Geodetic Survey Data Used"], "WGS-84")
    XCTAssertEqual(exifData["GPS"]?["GPS Tag Version"], "2.2.0.0")
    XCTAssertEqual(exifData["GPS"]?["GPS Measurement Mode"], "3")
    XCTAssertEqual(exifData["GPS"]?["Altitude Reference"], "Sea level reference")
  }

  func testIptcReadIptcData() {
    let rawUnsafeIptcData = iptc_data_new_from_jpeg(testImage)
    let iptcData = IptcData.new(imagePath: testImage)

    XCTAssertNotNil(rawUnsafeIptcData)
    XCTAssertNotNil(iptcData)

    let datasets = rawUnsafeIptcData!.pointee.datasets()
    let datasets2 = iptcData!.datasets()

    XCTAssertEqual(datasets.count, Int(rawUnsafeIptcData!.pointee.count))
    XCTAssertEqual(datasets2.count, Int(iptcData!.count))
    XCTAssertEqual(datasets.count, datasets2.count)

    let tuples = iptcData!.toTuples()

    XCTAssertEqual(tuples.count, datasets2.count)

    let dict = iptcData!.toDict()
    XCTAssertEqual(dict.count, 13)

    XCTAssertEqual(dict["Coded Character Set"] as! String, "1b 25 47")
    XCTAssertEqual(dict["Province/State"] as! String, "Noord-Holland")
    XCTAssertEqual(dict["By-line"] as! String, "Photographer: Kristoffer Andreas Dalby")
    XCTAssertEqual(dict["Country Name"] as! String, "Netherlands")
    XCTAssertEqual(dict["Digital Creation Time"] as! String, "133656")
    XCTAssertEqual(dict["Date Created"] as! String, "20180310")
    XCTAssertEqual(dict["Record Version"] as! String, "2")
    XCTAssertEqual(dict["City"] as! String, "Haarlem")
    XCTAssertEqual(dict["Digital Creation Date"] as! String, "20180310")
    XCTAssertEqual(dict["Time Created"] as! String, "133656")
    XCTAssertEqual(dict["Country Code"] as! String, "NL")
    XCTAssertEqual(
      dict["Copyright Notice"] as! String, "Copyright: Kristoffer Andreas Dalby")
    XCTAssertEqual(
      dict["Keywords"] as! [String],
      [
        "Dharmesh Tailor", "2018", "Alkmaar", "Dharmesh Tailor", "Dutch weekend adventures", "ESA",
        "Train", "YGT",
      ])

    let keywords = iptcData!.keywords()
    let keywordsFromDict = dict["Keywords"] as! [String]

    XCTAssertEqual(keywords.count, 8)
    XCTAssertEqual(keywords.count, keywordsFromDict.count)

  }

  static var __allTests = [
    ("test", test),
    ("testExifReadExifData", testExifReadExifData),
    ("testExifReadIfd", testExifReadIfd),
    ("testImageReadData", testImageReadData),
    ("testIptcReadIptcData", testIptcReadIptcData),
  ]
}
