import XCTest

@testable import SwiftExif
@testable import exif

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
    defer {
      exif_data_free(
        rawUnsafeExifData
      )
    }
    XCTAssertNotNil(rawUnsafeExifData)

    let contents = rawUnsafeExifData!.pointee.content()

    XCTAssertEqual(contents.count, 5)
  }

  func testImageReadData() {
    let image = Image(imagePath: URL(fileURLWithPath: testImage))
    let data = image.getData()

    XCTAssertNotNil(data)
    XCTAssertEqual(data.count, 6)

    XCTAssertTrue(data.keys.contains("undefined"))
    XCTAssertTrue(data.keys.contains("0"))
    XCTAssertTrue(data.keys.contains("1"))
    XCTAssertTrue(data.keys.contains("EXIF"))
    XCTAssertTrue(data.keys.contains("Interoperability"))
    XCTAssertTrue(data.keys.contains("GPS"))

    XCTAssertEqual(data["undefined"]?.count, 0)
    XCTAssertEqual(data["0"]?.count, 10)
    XCTAssertEqual(data["1"]?.count, 0)
    XCTAssertEqual(data["EXIF"]?.count, 31)
    XCTAssertEqual(data["Interoperability"]?.count, 0)
    XCTAssertEqual(data["GPS"]?.count, 9)

    XCTAssertEqual(data["0"]?["Orientation"], "Top-left")
    XCTAssertEqual(data["0"]?["Artist"], "Photographer: Kristoffer Andreas Dalby")
    XCTAssertEqual(
      data["0"]?["Copyright"],
      "Copyright: Kristoffer Andreas Dalby (Photographer) - [None] (Editor)")
    XCTAssertEqual(data["0"]?["Y-Resolution"], "72")
    XCTAssertEqual(data["0"]?["Manufacturer"], "Canon")
    XCTAssertEqual(data["0"]?["Model"], "Canon EOS 5D Mark II")
    XCTAssertEqual(data["0"]?["Date and Time"], "2018:03:10 13:36:56")
    XCTAssertEqual(data["0"]?["X-Resolution"], "72")
    XCTAssertEqual(data["0"]?["Software"], "Photos 4.0")
    XCTAssertEqual(data["0"]?["Resolution Unit"], "Inch")

    XCTAssertEqual(data["EXIF"]?["Camera Owner Name"], "Kristoffer Andreas Dalby")
    XCTAssertEqual(data["EXIF"]?["Body Serial Number"], "2431423523")
    XCTAssertEqual(data["EXIF"]?["Shutter Speed"], "7.32 EV (1/160 sec.)")
    XCTAssertEqual(data["EXIF"]?["Metering Mode"], "Pattern")
    XCTAssertEqual(data["EXIF"]?["White Balance"], "Auto white balance")
    XCTAssertEqual(data["EXIF"]?["FlashPixVersion"], "FlashPix Version 1.0")
    XCTAssertEqual(data["EXIF"]?["Color Space"], "sRGB")
    XCTAssertEqual(data["EXIF"]?["Exif Version"], "Exif Version 2.3")
    XCTAssertEqual(data["EXIF"]?["Scene Capture Type"], "Standard")
    XCTAssertEqual(data["EXIF"]?["Custom Rendered"], "Normal process")
    XCTAssertEqual(data["EXIF"]?["Sub-second Time (Digitized)"], "14")
    XCTAssertEqual(data["EXIF"]?["Focal Plane Y-Resolution"], "3908.142")
    XCTAssertEqual(data["EXIF"]?["Exposure Bias"], "0.00 EV")
    XCTAssertEqual(data["EXIF"]?["Pixel X Dimension"], "1280")
    XCTAssertEqual(data["EXIF"]?["Focal Plane X-Resolution"], "3849.212")
    XCTAssertEqual(data["EXIF"]?["Focal Plane Resolution Unit"], "Inch")
    XCTAssertEqual(data["EXIF"]?["Date and Time (Digitized)"], "2018:03:10 13:36:56")
    XCTAssertEqual(data["EXIF"]?["Lens Model"], "EF24-105mm f/4L IS USM")
    XCTAssertEqual(data["EXIF"]?["Date and Time (Original)"], "2018:03:10 13:36:56")
    XCTAssertEqual(data["EXIF"]?["Exposure Mode"], "Manual exposure")
    XCTAssertEqual(data["EXIF"]?["Pixel Y Dimension"], "853")
    XCTAssertEqual(data["EXIF"]?["Exposure Time"], "1/160 sec.")
    XCTAssertEqual(data["EXIF"]?["Flash"], "Flash did not fire, compulsory flash mode")
    XCTAssertEqual(data["EXIF"]?["ISO Speed Ratings"], "400")
    XCTAssertEqual(data["EXIF"]?["Sub-second Time (Original)"], "14")
    XCTAssertEqual(data["EXIF"]?["Maximum Aperture Value"], "4.00 EV (f/4.0)")
    XCTAssertEqual(data["EXIF"]?["Exposure Program"], "Manual")
    XCTAssertEqual(data["EXIF"]?["Focal Length"], "70.0 mm")
    XCTAssertEqual(data["EXIF"]?["Lens Specification"], "24, 105,  0,  0")
    XCTAssertEqual(data["EXIF"]?["Aperture"], "4.00 EV (f/4.0)")
    XCTAssertEqual(data["EXIF"]?["F-Number"], "f/4.0")

    XCTAssertEqual(data["GPS"]?["Altitude"], " 0")
    XCTAssertEqual(data["GPS"]?["North or South Latitude"], "N")
    XCTAssertEqual(data["GPS"]?["East or West Longitude"], "E")
    XCTAssertEqual(data["GPS"]?["Longitude"], " 4, 37, 41.88")
    XCTAssertEqual(data["GPS"]?["Latitude"], "52, 24, 18.89")
    XCTAssertEqual(data["GPS"]?["Geodetic Survey Data Used"], "WGS-84")
    XCTAssertEqual(data["GPS"]?["GPS Tag Version"], "2.2.0.0")
    XCTAssertEqual(data["GPS"]?["GPS Measurement Mode"], "3")
    XCTAssertEqual(data["GPS"]?["Altitude Reference"], "Sea level reference")
  }

  static var __allTests = [
    ("test", test),
    ("testExifReadExifData", testExifReadExifData),
    ("testImageReadData", testImageReadData),
  ]
}
