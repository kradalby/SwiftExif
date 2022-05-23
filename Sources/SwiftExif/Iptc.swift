import Foundation
import iptc

extension IptcData {
  
  static func new(imagePath: String) -> IptcData? {
    let rawUnsafeIptcData = iptc_data_new_from_jpeg(imagePath)
    
    if let rawIptcData = rawUnsafeIptcData {
      return rawIptcData.pointee
    }
    
    return nil
  }
  
  
  static func new(_ data: Data) -> IptcData? {
    data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
      let rawUnsafeIptcData = iptc_data_new_from_data(bytes, UInt32(data.count))
      
      if let rawIptcData = rawUnsafeIptcData {
        return rawIptcData.pointee
      }
      
      return nil
    }
    
  }
  
  func datasets() -> [IptcDataSet] {
    if let rawDataset = self.datasets {
      let datasets = Array(
        UnsafeBufferPointer(
          start: rawDataset,
          count: Int(self.count)
        )
      )
      
      return datasets.compactMap({ $0?.pointee })
    }
    
    return []
  }
  
  func toTuples() -> [(String, String)] {
    var list = [(String, String)]()
    for var dataset in self.datasets() {
      if let tuple = dataset.toTuple() {
        list.append(tuple)
      }
    }
    return list
  }
  
  func toDict() -> [String: Any] {
    var result = [String: Any]()
    for (key, value) in self.toTuples() {
      if result.keys.contains(key) {
        if var currentValue = result[key] as? [String] {
          currentValue.append(value)
          result[key] = currentValue
        } else if let currentValue = result[key] as? String {
          result[key] = [currentValue, value]
        }
      } else {
        result[key] = value
      }
    }
    
    return result
  }
  
  func keywords() -> [String] {
    return self.toTuples().compactMap({ (key, value) -> String? in
      return key == "Keywords" ? value : nil
    })
  }
  
}

extension IptcDataSet {
  mutating func value() -> String {
    let value = UnsafeMutablePointer<Int8>.allocate(capacity: 256)
    iptc_dataset_get_as_str(&self, value, 256)
    
    let str = String(cString: value)
    return str
  }
  
  func tagTitle() -> String? {
    let value = iptc_tag_get_title(self.record, self.tag)
    
    let str = String(cString: value)
    return str
  }
  
  mutating func format() -> IptcFormat {
    iptc_dataset_get_format(&self)
  }
  
  mutating func formatName() -> String? {
    let value = iptc_format_get_name(self.format())
    
    let str = String(cString: value)
    return str
  }
  
  mutating func toTuple() -> (String, String)? {
    if let key = self.tagTitle() {
      return (key, self.value())
    }
    return nil
  }
}
