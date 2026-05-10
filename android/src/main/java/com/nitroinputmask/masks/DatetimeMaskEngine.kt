package com.nitroinputmask.masks

import com.nitroinputmask.engine.CompiledMask
import com.nitroinputmask.engine.MaskEngine
import com.nitroinputmask.engine.MaskEngineProtocol

internal class DatetimeMaskEngine(format: String) : MaskEngineProtocol {
  private val compiled: CompiledMask = MaskEngine.compile(formatToPattern(format))

  override fun apply(input: String): Pair<String, String> {
    return MaskEngine.apply(input, compiled)
  }

  override val wantsTrailingCursor: Boolean = false
  override val expandedMask: String? = compiled.expandedMask

  companion object {
    private fun formatToPattern(format: String): String {
      val sb = StringBuilder()
      var i = 0

      while (i < format.length) {
        when {
          format.startsWith("YYYY", i) -> { sb.append("9999");    i += 4 }
          format.startsWith("MM",   i) -> { sb.append("[1-12]");  i += 2 }
          format.startsWith("DD",   i) -> { sb.append("[1-31]");  i += 2 }
          format.startsWith("HH",   i) -> { sb.append("[0-23]");  i += 2 }
          format.startsWith("hh",   i) -> { sb.append("[1-12]");  i += 2 }
          format.startsWith("mm",   i) -> { sb.append("[0-59]");  i += 2 }
          format.startsWith("ss",   i) -> { sb.append("[0-59]");  i += 2 }
          else -> { sb.append(format[i]); i++ }
        }
      }

      return sb.toString()
    }
  }
}
