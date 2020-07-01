extension String {
  init?(cString: UnsafeMutablePointer<Int8>?) {
    guard let cString = cString else { return nil }
    self = String(cString: cString)
  }

  init?(cString: UnsafeMutablePointer<CUnsignedChar>?) {
    guard let cString = cString else { return nil }
    self = String(cString: cString)
  }

  init?(cString: Any) {

    if let pointer = cString as? UnsafeMutablePointer<CChar> {
      self = String(cString: pointer)
      return
    }

    if let pointer = cString as? UnsafeMutablePointer<CUnsignedChar> {
      self = String(cString: pointer)
      return
    }

    return nil
  }
}

extension UnsafeMutablePointer {
  func toArray(capacity: Int) -> [Pointee] {
    return Array(UnsafeBufferPointer(start: self, count: capacity))
  }
}
