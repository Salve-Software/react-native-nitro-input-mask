import NitroModules

struct MoneyMaskEngine: MaskEngineProtocol {
  private let precision: Int
  private let separator: String
  private let delimiter: String
  private let unit: String
  private let suffixUnit: String
  private let zeroCents: Bool

  init(options: NitroMaskOptions) {
    self.precision   = Int(options.precision ?? 2)
    self.separator   = options.separator  ?? ","
    self.delimiter   = options.delimiter  ?? "."
    self.unit        = options.unit       ?? ""
    self.suffixUnit  = options.suffixUnit ?? ""
    self.zeroCents   = options.zeroCents  ?? false
  }

  func apply(input: String) -> (masked: String, raw: String) {
    let digits = input.filter { $0.isNumber }

    if digits.isEmpty {
      return ("", "")
    }

    let effectivePrecision = zeroCents ? 0 : precision

    // Pad on the left so we have at least (precision+1) digits
    let minLength = effectivePrecision + 1
    let padded = String(repeating: "0", count: max(0, minLength - digits.count)) + digits

    // Split integer and decimal parts
    let splitIdx: String.Index
    if effectivePrecision > 0 {
      splitIdx = padded.index(padded.endIndex, offsetBy: -effectivePrecision)
    } else {
      splitIdx = padded.endIndex
    }

    var intPart = String(padded[padded.startIndex..<splitIdx])
    let centPart = effectivePrecision > 0 ? String(padded[splitIdx...]) : ""

    // Remove leading zeros from intPart, keep at least "0"
    while intPart.count > 1 && intPart.hasPrefix("0") {
      intPart = String(intPart.dropFirst())
    }

    // Insert delimiter every 3 digits from right
    var formattedInt = ""
    let intChars = Array(intPart)
    let total = intChars.count
    for (i, c) in intChars.enumerated() {
      formattedInt.append(c)
      let remaining = total - i - 1
      if remaining > 0 && remaining % 3 == 0 {
        formattedInt += delimiter
      }
    }

    // Build result
    var masked = unit + formattedInt
    if effectivePrecision > 0 {
      masked += separator + centPart
    }
    masked += suffixUnit

    return (masked, digits)
  }

  var wantsTrailingCursor: Bool { true }
  var expandedMask: String? { nil }
}
