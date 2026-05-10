package com.nitroinputmask

import androidx.annotation.Keep
import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.nitroinputmask.HybridNitroInputMaskServiceSpec

@Keep
@DoNotStrip
class HybridNitroInputMaskServiceModule : HybridNitroInputMaskServiceSpec() {
  override fun applyMask(value: String, mask: String): String {
    val compiled = MaskEngine.compile(mask)
    val (masked, _) = MaskEngine.apply(value, compiled)
    return masked
  }
}
