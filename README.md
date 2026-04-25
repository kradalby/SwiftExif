# SwiftExif

Swift wrapper around [libexif](https://libexif.github.io) and
[libiptcdata](http://libiptcdata.sourceforge.net) for reading EXIF and
IPTC metadata out of JPEG files on Linux and macOS.

## Status

Built for and primarily used by [Munin](https://github.com/kradalby/munin),
a static photo gallery generator that needs EXIF and IPTC reads on Linux
and macOS without ImageIO/CoreGraphics. The library is general; maintenance
cadence is driven by what Munin asks for, but PRs from other consumers are
welcome.

## Requirements

- Swift 6.3+
- Linux or macOS
- libexif and libiptcdata, installed system-wide and discoverable via
  `pkg-config`

```bash
# Debian / Ubuntu
apt install libexif-dev libiptcdata0-dev

# macOS
brew install libexif libiptcdata
```

## Use

```swift
.package(url: "https://github.com/kradalby/SwiftExif.git", from: "0.1.0"),
```

```swift
import SwiftExif

let result = try Image.parse(at: fileURL)

// Human-readable EXIF, keyed [ifd][tag] — ifds are "0", "1", "EXIF",
// "GPS", "Interoperability". Empty when the source has no EXIF block.
let exif: [String: [String: String]] = result.exif

// Raw EXIF, same shape; use this when you want numeric values without
// libexif's localised rendering.
let exifRaw: [String: [String: String]] = result.exifRaw

// EXIF Orientation tag, decoded; nil when absent.
let orientation: Orientation? = result.orientation

// IPTC, typed. The four string fields Munin reads are pulled out of
// the IPTC blob; everything else lands in extras.
let iptc: IptcFields = result.iptc
print(iptc.keywords)        // [String]
print(iptc.city)             // String?
print(iptc.countryName)      // String?
print(iptc.extras["Date Created"])
```

`parse(at:)` throws `ParseError.fileUnreadable` when the path doesn't
resolve to a readable file. A readable file with no EXIF or IPTC is
not an error: the dicts come back empty and `orientation` is `nil`.

For in-memory bytes:

```swift
let result = Image.parse(data: jpegBytes)   // never throws; empty result on garbage
```

`ExifResult`, `IptcFields`, `Orientation`, and `ParseError` are
`Sendable`, so the result crosses task boundaries without an
`@unchecked` wrapper.

## How it builds

Two system library targets (`exif`, `iptc`) bind libexif and
libiptcdata through their public headers via `pkg-config`. A third C
target, `ExifFormat`, reimplements `exif_entry_format_value` — a
function that remains private in libexif's installed headers as of
0.6.25 — so the Swift code can format raw EXIF values without forking
libexif itself.

## Versioning

- **0.1.0** — current. Adds `Image.parse(at:)` / `parse(data:)`
  returning a `Sendable` `ExifResult`, frees libexif/libiptcdata
  allocations after extraction, and migrates the test suite to
  swift-testing. The legacy dict-returning API
  (`Image(imagePath:)`/`Exif()`/`ExifRaw()`/`ExifWithRaw()`/`Iptc()`)
  keeps working unchanged but emits `@available(*, deprecated)`
  warnings pointing at `parse(at:)`. Removal no earlier than 0.2.0.
- **0.0.7** — last release before this one. Predates the Swift 6.3
  nullability fix and is not Sendable-friendly. Migrate via
  `from: "0.1.0"`.

## Known limitations

- IPTC keyword decoding ignores the per-block charset declaration that
  ExifTool emits, so non-ASCII keywords on those exports come back
  mojibake'd. The corresponding test is annotated with
  `withKnownIssue`. Fix is queued for a follow-up minor.
