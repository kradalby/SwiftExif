extension String {
  init?(nullableCString: UnsafeMutablePointer<Int8>?) {
    guard let nullableCString else { return nil }
    self = String(cString: nullableCString)
  }

  init?(nullableCString: UnsafeMutablePointer<CUnsignedChar>?) {
    guard let nullableCString else { return nil }
    self = String(cString: nullableCString)
  }

  init?(nullableCString: Any) {

    if let pointer = nullableCString as? UnsafeMutablePointer<CChar> {
      self = String(cString: pointer)
      return
    }

    if let pointer = nullableCString as? UnsafeMutablePointer<CUnsignedChar> {
      self = String(cString: pointer)
      return
    }

    return nil
  }
}
