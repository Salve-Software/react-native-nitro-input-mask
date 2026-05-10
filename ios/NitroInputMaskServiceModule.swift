import NitroModules

class HybridNitroInputMaskServiceModule: HybridNitroInputMaskServiceSpec_base, HybridNitroInputMaskServiceSpec_protocol {
  // `throws` is required by the Nitro bridge protocol, consistent with HybridNitroInputMaskModule.
  // MaskEngine itself never throws; errors surface as bridge-level exceptions if needed.
  func applyMask(value: String, mask: String) throws -> String {
    let compiled = MaskEngine.compile(mask: mask)
    let (masked, _) = MaskEngine.apply(input: value, compiled: compiled)
    return masked
  }
}
