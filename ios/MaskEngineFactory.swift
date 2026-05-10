import NitroModules

enum MaskEngineFactory {
  static func build(maskType: String, options: NitroMaskOptions) -> MaskEngineProtocol {
    switch maskType {
    case "money":
      return MoneyMaskEngine(options: options)
    case "datetime":
      return DatetimeMaskEngine(format: options.format ?? "DD/MM/YYYY")
    case "credit-card":
      return CreditCardMaskEngine(options: options)
    default: // "custom"
      return CustomMaskEngine(mask: options.mask ?? "")
    }
  }
}
