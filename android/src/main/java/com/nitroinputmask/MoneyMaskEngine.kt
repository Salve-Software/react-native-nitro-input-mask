package com.nitroinputmask

import com.margelo.nitro.nitroinputmask.NitroMaskOptions

internal class MoneyMaskEngine(options: NitroMaskOptions) : MaskEngineProtocol {
  private val precision: Int = (options.precision?.toInt()) ?: 2
  private val separator: String = options.separator ?: ","
  private val delimiter: String = options.delimiter ?: "."
  private val unit: String = options.unit ?: ""
  private val suffixUnit: String = options.suffixUnit ?: ""
  private val zeroCents: Boolean = options.zeroCents ?: false

  override fun apply(input: String): Pair<String, String> {
    val digits = input.filter { it.isDigit() }

    if (digits.isEmpty()) {
      return Pair("", "")
    }

    val effectivePrecision = if (zeroCents) 0 else precision

    // Pad on the left so we have at least (precision+1) digits
    val minLength = effectivePrecision + 1
    val padded = digits.padStart(maxOf(minLength, digits.length), '0')

    // Split integer and decimal parts
    var intPart: String
    val centPart: String
    if (effectivePrecision > 0) {
      intPart = padded.dropLast(effectivePrecision)
      centPart = padded.takeLast(effectivePrecision)
    } else {
      intPart = padded
      centPart = ""
    }

    // Remove leading zeros from intPart, keep at least "0"
    while (intPart.length > 1 && intPart.startsWith('0')) {
      intPart = intPart.drop(1)
    }

    // Insert delimiter every 3 digits from right
    val sb = StringBuilder()
    val total = intPart.length
    for (i in intPart.indices) {
      sb.append(intPart[i])
      val remaining = total - i - 1
      if (remaining > 0 && remaining % 3 == 0) {
        sb.append(delimiter)
      }
    }

    // Build result
    var masked = unit + sb.toString()
    if (effectivePrecision > 0) {
      masked += separator + centPart
    }
    masked += suffixUnit

    return Pair(masked, digits)
  }

  override val wantsTrailingCursor: Boolean = true
  override val expandedMask: String? = null
}
