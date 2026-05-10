package com.nitroinputmask

import com.margelo.nitro.nitroinputmask.NitroMaskOptions

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
