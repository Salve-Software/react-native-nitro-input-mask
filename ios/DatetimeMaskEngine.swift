import NitroModules

struct DatetimeMaskEngine: MaskEngineProtocol {
  private let compiled: CompiledMask

  init(format: String) {
    let pattern = DatetimeMaskEngine.formatToPattern(format)
    self.compiled = MaskEngine.compile(mask: pattern)
  }

  func apply(input: String) -> (masked: String, raw: String) {
    return MaskEngine.apply(input: input, compiled: compiled)
  }

  var wantsTrailingCursor: Bool { false }
  var expandedMask: String? { compiled.expandedMask }

  // MARK: - Format → Pattern conversion

  private static func formatToPattern(_ format: String) -> String {
    var result = ""
    var i = format.startIndex

    while i < format.endIndex {
      // Match longer tokens first
      if format[i...].hasPrefix("YYYY") {
        result += "9999"
        i = format.index(i, offsetBy: 4)
      } else if format[i...].hasPrefix("MM") {
        result += "[1-12]"
        i = format.index(i, offsetBy: 2)
      } else if format[i...].hasPrefix("DD") {
        result += "[1-31]"
        i = format.index(i, offsetBy: 2)
      } else if format[i...].hasPrefix("HH") {
        result += "[0-23]"
        i = format.index(i, offsetBy: 2)
      } else if format[i...].hasPrefix("hh") {
        result += "[1-12]"
        i = format.index(i, offsetBy: 2)
      } else if format[i...].hasPrefix("mm") {
        result += "[0-59]"
        i = format.index(i, offsetBy: 2)
      } else if format[i...].hasPrefix("ss") {
        result += "[0-59]"
        i = format.index(i, offsetBy: 2)
      } else {
        result.append(format[i])
        i = format.index(after: i)
      }
    }

    return result
  }
}
