import NitroModules

class HybridNitroInputMaskServiceModule: HybridNitroInputMaskServiceSpec_base,
  HybridNitroInputMaskServiceSpec_protocol
{
  func applyMask(value: String, maskType: String, options: NitroMaskOptions) throws -> MaskResult {
    let engine = MaskEngineFactory.build(maskType: maskType, options: options)
    let (masked, raw) = engine.apply(input: value)
    return MaskResult(masked: masked, raw: raw)
  }
}
