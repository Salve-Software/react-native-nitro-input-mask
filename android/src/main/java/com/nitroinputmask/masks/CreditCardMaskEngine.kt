package com.nitroinputmask.masks

import com.margelo.nitro.nitroinputmask.NitroMaskOptions
import com.nitroinputmask.engine.CompiledMask
import com.nitroinputmask.engine.MaskEngine
import com.nitroinputmask.engine.MaskEngineProtocol

internal class CreditCardMaskEngine(options: NitroMaskOptions) : MaskEngineProtocol {
  private val compiled: CompiledMask
  private val obfuscated: Boolean = options.obfuscated ?: false

  init {
    val mask = when (options.issuer) {
      "amex"   -> "9999 999999 99999"
      "diners" -> "9999 999999 9999"
      else     -> "9999 9999 9999 9999" // visa-or-mastercard (default)
    }
    compiled = MaskEngine.compile(mask)
  }

  override fun apply(input: String): Pair<String, String> {
    val (masked, raw) = MaskEngine.apply(input, compiled)

    if (obfuscated && masked.isNotEmpty()) {
      return Pair(obfuscate(masked), raw)
    }

    return Pair(masked, raw)
  }

  override val wantsTrailingCursor: Boolean = false
  override val expandedMask: String? = compiled.expandedMask

  private fun obfuscate(masked: String): String {
    val lastSpaceIdx = masked.lastIndexOf(' ')
    if (lastSpaceIdx == -1) return masked // single group — don't obfuscate

    val prefix = masked.substring(0, lastSpaceIdx + 1)
    val lastGroup = masked.substring(lastSpaceIdx + 1)

    val obfuscatedPrefix = prefix.map { c ->
      if (c.isDigit()) '*' else c
    }.joinToString("")

    return obfuscatedPrefix + lastGroup
  }
}
