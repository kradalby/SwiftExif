# SwiftExif

SwiftExif is a wrapping library for [libexif](https://libexif.github.io) and [libiptcdata](http://libiptcdata.sourceforge.net) for Swift
to provide a JPEG metadata extraction on Linux and macOS.

SwiftExif was written to facilitate porting the
[Munin](https://github.com/kradalby/munin) image
gallery generator to run on both Linux and macOS (it previously required
ImageIO/CoreGraphics).

[libexif](https://libexif.github.io) is used to extract and format the EXIF data from the image, while
[libiptcdata](http://libiptcdata.sourceforge.net) extracts the "newer" IPTC standard.

## Requirements

- Linux (Ubuntu 20.10 tested) or macOS (10.15 tested)
- Swift 5.2 (or newer)
- libexif 0.6.22 (available in Homebrew or Ubuntu 20.10)
- libiptcdata 1.0.4

## Installation

On Ubuntu/Debian based Linux:

```bash
apt install -y libiptc-data libexif-dev libiptcdata0-dev
```

On macOS using brew:

```bash
brew install libexif libiptcdata
```

### Swift Package Manager

Add SwiftExif to your dependencies:

```swift
dependencies: [
  .package(url: "https://github.com/kradalby/SwiftExif.git", from: "0.0.x"),
]
```

## Usage

SwiftExif aims to provide some simple helper functions that essentially returns
all the data as dictionaries.

For example:

```swift
import SwiftExif

// Read a JPEG file and return an Image object
// Note: current error behaviour is to return empty dictionaries, no error is thrown.
let exifImage = SwiftExif.Image(imagePath: fileURL)

// Get a [String : [String : String]] dictionary. The first dictionary has items
// from the spec e.g. 0, 1, EXIF, GPS...
// The values are returned in "human readable format".
let exifDict = exifImage.Exif()

// Get a [String : [String : String]] dictionary. The first dictionary has items
// from the spec e.g. 0, 1, EXIF, GPS...
// The values are returned in a "raw" format.
let exifRawDict = exifImage.ExifRaw()

// Get a [String : Any] dictionary.
// Most items are String, however "Keywords" are [String]
let iptcDict = exifImage.Iptc()
```

In addition to the high-level functions, a set of lower-level functions is
available in the different classes.
Have a look at the code or the unit tests to see what else you can do.
