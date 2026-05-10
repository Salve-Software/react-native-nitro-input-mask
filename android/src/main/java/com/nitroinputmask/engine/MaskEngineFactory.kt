package com.nitroinputmask.engine

import com.margelo.nitro.nitroinputmask.NitroMaskOptions
import com.nitroinputmask.masks.CreditCardMaskEngine
import com.nitroinputmask.masks.CustomMaskEngine
import com.nitroinputmask.masks.DatetimeMaskEngine
import com.nitroinputmask.masks.MoneyMaskEngine

internal object MaskEngineFactory {
  fun build(maskType: String, options: NitroMaskOptions): MaskEngineProtocol {
    return when (maskType) {
      "money"       -> MoneyMaskEngine(options)
      "datetime"    -> DatetimeMaskEngine(options.format ?: "DD/MM/YYYY")
      "credit-card" -> CreditCardMaskEngine(options)
      else          -> CustomMaskEngine(options.mask ?: "") // "custom"
    }
  }
}
