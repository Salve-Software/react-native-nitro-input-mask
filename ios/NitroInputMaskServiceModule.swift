import NitroModules

class HybridNitroInputMaskServiceModule: HybridNitroInputMaskServiceSpec_base, HybridNitroInputMaskServiceSpec_protocol {
  func applyMask(value: String, mask: String) throws -> String {
    let compiled = MaskEngine.compile(mask: mask)
    let (masked, _) = MaskEngine.apply(input: value, compiled: compiled)
    return masked
  }
}
