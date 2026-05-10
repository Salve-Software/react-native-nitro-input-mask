package com.nitroinputmask.masks

import com.nitroinputmask.engine.CompiledMask
import com.nitroinputmask.engine.MaskEngine
import com.nitroinputmask.engine.MaskEngineProtocol

internal class CustomMaskEngine(mask: String) : MaskEngineProtocol {
  private val compiled: CompiledMask = MaskEngine.compile(mask)

  override fun apply(input: String): Pair<String, String> {
    return MaskEngine.apply(input, compiled)
  }

  override val wantsTrailingCursor: Boolean = false
  override val expandedMask: String? = compiled.expandedMask
}
