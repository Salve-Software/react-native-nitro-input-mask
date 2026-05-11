package com.nitroinputmask

import androidx.annotation.Keep
import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.nitroinputmask.HybridNitroInputMaskServiceSpec
import com.margelo.nitro.nitroinputmask.NitroMaskOptions
import com.nitroinputmask.engine.MaskEngineFactory

@Keep
@DoNotStrip
class HybridNitroInputMaskServiceModule : HybridNitroInputMaskServiceSpec() {
  override fun applyMask(value: String, maskType: String, options: NitroMaskOptions): MaskResult {
    val engine = MaskEngineFactory.build(maskType, options)
    val (masked, raw) = engine.apply(value)
    return MaskResult(masked = masked, raw = raw)
  }
}
