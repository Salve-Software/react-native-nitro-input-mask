import NitroModules

class HybridNitroInputMaskServiceModule: HybridNitroInputMaskServiceSpec_base, HybridNitroInputMaskServiceSpec_protocol {
  func applyMask(value: String, maskType: String, options: NitroMaskOptions) throws -> String {
    let engine = MaskEngineFactory.build(maskType: maskType, options: options)
    let (masked, _) = engine.apply(input: value)
    return masked
  }
}
