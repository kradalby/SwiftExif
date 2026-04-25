import Foundation
import Testing

@testable import SwiftExif

private let testsDirectoryURL = URL(fileURLWithPath: #filePath)
  .deletingLastPathComponent()
  .deletingLastPathComponent()

private func fixture(_ name: String) -> URL {
  testsDirectoryURL.appendingPathComponent(name)
}

private let testImage = fixture("test.jpg")
private let testImageSpecialCharacters = fixture("test_special_chars.jpg")
private let testImagePhotosExport = fixture("photos_export.jpg")
private let testImageOSXPhotosExifExport = fixture("osxphotos_exif_export.jpg")

@Suite("SwiftExif")
struct SwiftExifTests {

  // MARK: - Typed parse(at:) — happy path

  @Test func parseAtURLProducesAllFiveIFDs() throws {
    let result = try Image.parse(at: testImage)

    #expect(result.exif.count == 5)
    #expect(Set(result.exif.keys) == ["0", "1", "EXIF", "GPS", "Interoperability"])
    #expect(result.exif["EXIF"]?.count == 31)
    #expect(result.exif["GPS"]?.count == 9)
  }

  @Test func parseAtURLPopulatesHumanReadableEXIF() throws {
    let result = try Image.parse(at: testImage)

    #expect(result.exif["0"]?["Manufacturer"] == "Canon")
    #expect(result.exif["0"]?["Model"] == "Canon EOS 5D Mark II")
    #expect(result.exif["0"]?["Date and Time"] == "2018:03:10 13:36:56")
    #expect(result.exif["EXIF"]?["F-Number"] == "f/4.0")
    #expect(result.exif["GPS"]?["Longitude"] == "4, 37, 41.88")
  }

  @Test func parseAtURLPopulatesRawEXIF() throws {
    let result = try Image.parse(at: testImage)

    #expect(result.exifRaw["EXIF"]?["F-Number"] == "4")
    #expect(result.exifRaw["EXIF"]?["Aperture"] == "4")
    #expect(result.exifRaw["GPS"]?["East or West Longitude"] == "E")
  }

  @Test func parseAtURLDecodesOrientation() throws {
    let result = try Image.parse(at: testImage)
    #expect(result.orientation == .normal)
  }

  // MARK: - Typed IPTC

  @Test func iptcFieldsBreakOutTheTypedSlots() throws {
    let iptc = try Image.parse(at: testImage).iptc

    #expect(iptc.city == "Haarlem")
    #expect(iptc.provinceState == "Noord-Holland")
    #expect(iptc.countryCode == "NL")
    #expect(iptc.countryName == "Netherlands")
    #expect(iptc.keywords.count == 8)
    #expect(iptc.keywords.contains("Dutch weekend adventures"))
  }

  @Test func iptcExtrasContainsUntypedFields() throws {
    let iptc = try Image.parse(at: testImage).iptc

    // Typed slots are absent from extras.
    #expect(iptc.extras["City"] == nil)
    #expect(iptc.extras["Keywords"] == nil)

    // Other fields land in extras as-is.
    #expect(iptc.extras["Date Created"] == "20180310")
    #expect(iptc.extras["Copyright Notice"] == "Copyright: Kristoffer Andreas Dalby")
    #expect(iptc.extras["By-line"] == "Photographer: Kristoffer Andreas Dalby")
  }

  @Test func iptcKeywordsDecodeNonASCII() throws {
    let iptc = try Image.parse(at: testImageSpecialCharacters).iptc
    #expect(iptc.keywords.count == 4)
    #expect(iptc.keywords.contains("Midtøsten"))
  }

  @Test func iptcKeywordsFromMacOSPhotosExport() throws {
    let iptc = try Image.parse(at: testImagePhotosExport).iptc
    #expect(iptc.keywords.count == 2)
    #expect(iptc.keywords.contains("Påbygging"))
    #expect(iptc.keywords.contains("Julebord"))
  }

  // libiptcdata decodes osxphotos_exif_export.jpg's keywords with the wrong
  // charset, producing mojibake'd bytes. Tracked alongside the IPTC encoding
  // rework that lands in a follow-up minor.
  @Test func iptcKeywordsFromExifToolExport() throws {
    withKnownIssue("IPTC charset handling broken on ExifTool exports") {
      let iptc = try Image.parse(at: testImageOSXPhotosExifExport).iptc
      #expect(iptc.keywords.count == 2)
      #expect(iptc.keywords.contains("Påbygging"))
      #expect(iptc.keywords.contains("Julebord"))
    }
  }

  // MARK: - parse(data:) parity & invalid bytes

  @Test func parseDataMatchesParseURL() throws {
    let bytes = try Data(contentsOf: testImage)
    let fromURL = try Image.parse(at: testImage)
    let fromData = Image.parse(data: bytes)
    #expect(fromURL == fromData)
  }

  @Test func parseDataInvalidBytesYieldEmptyResult() {
    let result = Image.parse(data: Data([0x00, 0x01, 0x02, 0x03]))
    #expect(result.exif.isEmpty)
    #expect(result.exifRaw.isEmpty)
    #expect(result.iptc.keywords.isEmpty)
    #expect(result.iptc.extras.isEmpty)
    #expect(result.orientation == nil)
  }

  @Test func parseDataEmptyDataYieldsEmptyResult() {
    let result = Image.parse(data: Data())
    #expect(result == ExifResult(exif: [:], exifRaw: [:], iptc: IptcFields(), orientation: nil))
  }

  // MARK: - Error paths

  @Test func parseAtURLThrowsWhenFileMissing() {
    let missing = URL(fileURLWithPath: "/nonexistent/path/missing.jpg")
    #expect(throws: ParseError.fileUnreadable(missing)) {
      try Image.parse(at: missing)
    }
  }

  @Test func parseAtURLOnNonJPEGProducesEmptyResult() throws {
    let tmp = FileManager.default.temporaryDirectory
      .appendingPathComponent("swiftexif-invalid-\(UUID().uuidString).bin")
    try Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]).write(to: tmp)
    defer { try? FileManager.default.removeItem(at: tmp) }

    let result = try Image.parse(at: tmp)
    #expect(result.exif.isEmpty)
    #expect(result.iptc.keywords.isEmpty)
    #expect(result.orientation == nil)
  }

  // MARK: - Sendable boundary

  @Test func resultCrossesTaskBoundary() async throws {
    let result = try Image.parse(at: testImage)
    let returned = await Task { result }.value
    #expect(returned == result)
  }

  // MARK: - Deprecated dict API (kept covered through 0.1.x)

  @Test func deprecatedImageInitStillReadsEXIFAndIPTC() {
    let exif = legacyExif(at: testImage)
    let iptc = legacyIptc(at: testImage)

    #expect(exif.count == 5)
    #expect(exif["0"]?["Manufacturer"] == "Canon")
    #expect(iptc["City"] as? String == "Haarlem")
    #expect((iptc["Keywords"] as? [String])?.count == 8)
  }
}

@available(*, deprecated)
private func legacyExif(at url: URL) -> [String: [String: String]] {
  Image(imagePath: url).Exif()
}

@available(*, deprecated)
private func legacyIptc(at url: URL) -> [String: Any] {
  Image(imagePath: url).Iptc()
}
