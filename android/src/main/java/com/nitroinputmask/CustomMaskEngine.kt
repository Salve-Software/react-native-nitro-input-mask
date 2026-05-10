package com.nitroinputmask

internal class CustomMaskEngine(mask: String) : MaskEngineProtocol {
  private val compiled: CompiledMask = MaskEngine.compile(mask)

  override fun apply(input: String): Pair<String, String> {
    return MaskEngine.apply(input, compiled)
  }

  override val wantsTrailingCursor: Boolean = false
  override val expandedMask: String? = compiled.expandedMask
}
