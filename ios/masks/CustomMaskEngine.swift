import NitroModules

struct CustomMaskEngine: MaskEngineProtocol {
  private let compiled: CompiledMask

  init(mask: String) {
    self.compiled = MaskEngine.compile(mask: mask)
  }

  func apply(input: String) -> (masked: String, raw: String) {
    return MaskEngine.apply(input: input, compiled: compiled)
  }

  var wantsTrailingCursor: Bool { false }
  var expandedMask: String? { compiled.expandedMask }
}
