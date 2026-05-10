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

  private static let tokens: [(token: String, pattern: String)] = [
    ("YYYY", "9999"),
    ("MM", "[1-12]"),
    ("DD", "[1-31]"),
    ("HH", "[0-23]"),
    ("hh", "[1-12]"),
    ("mm", "[0-59]"),
    ("ss", "[0-59]"),
  ]

  private static func formatToPattern(_ format: String) -> String {
    var result = ""
    var i = format.startIndex

    while i < format.endIndex {
      if let match = tokens.first(where: { format[i...].hasPrefix($0.token) }) {
        result += match.pattern
        i = format.index(i, offsetBy: match.token.count)
      } else {
        result.append(format[i])
        i = format.index(after: i)
      }
    }

    return result
  }
}
