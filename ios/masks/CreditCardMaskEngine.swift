import NitroModules

struct CreditCardMaskEngine: MaskEngineProtocol {
  private let compiled: CompiledMask
  private let obfuscated: Bool

  init(options: NitroMaskOptions) {
    let issuer = options.issuer ?? "visa-or-mastercard"
    self.obfuscated = options.obfuscated ?? false

    let mask: String
    switch issuer {
    case "amex":
      mask = "9999 999999 99999"
    case "diners":
      mask = "9999 999999 9999"
    default: // visa-or-mastercard
      mask = "9999 9999 9999 9999"
    }

    self.compiled = MaskEngine.compile(mask: mask)
  }

  func apply(input: String) -> (masked: String, raw: String) {
    let (masked, raw) = MaskEngine.apply(input: input, compiled: compiled)

    if obfuscated && !masked.isEmpty {
      let obfuscatedMasked = CreditCardMaskEngine.obfuscate(masked)
      return (obfuscatedMasked, raw)
    }

    return (masked, raw)
  }

  var wantsTrailingCursor: Bool { false }
  var expandedMask: String? { compiled.expandedMask }

  // MARK: - Obfuscation

  private static func obfuscate(_ masked: String) -> String {
    guard let lastSpaceIdx = masked.lastIndex(of: " ") else {
      // No spaces — single group, don't obfuscate
      return masked
    }

    let lastGroupStart = masked.index(after: lastSpaceIdx)
    let prefix = String(masked[masked.startIndex..<lastGroupStart])
    let lastGroup = String(masked[lastGroupStart...])

    // Replace digit characters with * in prefix, keep spaces intact
    let obfuscatedPrefix = prefix.map { c -> Character in
      c.isNumber ? "*" : c
    }

    return String(obfuscatedPrefix) + lastGroup
  }
}
