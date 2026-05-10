package com.nitroinputmask

// ---------------------------------------------------------------------------
// Slot — private internal representation of each compiled mask position
// ---------------------------------------------------------------------------

internal sealed class Slot {
  object Digit : Slot()
  object Letter : Slot()
  object Any : Slot()
  data class Literal(val char: Char) : Slot()

  /**
   * A slot that belongs to an inline `[from-to]` range.
   *
   * @param blockName  the range content string, e.g. "1-12" (used as the
   *                   partial-tracking key; two ranges with identical bounds
   *                   will share partial state — acceptable trade-off)
   * @param position   0-based index of this slot within the range block
   * @param length     total character width (= max(from.digits, to.digits))
   * @param from       inclusive lower bound of the valid range
   * @param to         inclusive upper bound of the valid range
   */
  data class RangeSlot(
    val blockName: String,
    val length: Int,
    val from: Int,
    val to: Int
  ) : Slot()
}

// ---------------------------------------------------------------------------
// CompiledMask — result of compile(); shared between MaskEngine and callers
// ---------------------------------------------------------------------------

internal data class CompiledMask(
  internal val slots: List<Slot>,
  /** Expanded mask string used by CursorEngine (range positions become '9'). */
  val expandedMask: String
) {
  val isEmpty: Boolean get() = slots.isEmpty()
}

// ---------------------------------------------------------------------------
// MaskEngine
// ---------------------------------------------------------------------------

object MaskEngine {

  // -------------------------------------------------------------------------
  // compile
  // -------------------------------------------------------------------------

  /**
   * Compiles a mask string into a [CompiledMask].
   *
   * Supported tokens:
   * - `9`         — any digit
   * - `A`         — any letter
   * - `*`         — any alphanumeric
   * - `[from-to]` — integer range, e.g. `[1-12]`, `[1-31]`, `[0-23]`
   * - any other character — literal
   *
   * Note: two `[from-to]` blocks with identical bounds share the same
   * `blockName` key and therefore share partial-tracking state during
   * [apply]. This is an acceptable trade-off; prefer distinct bounds when
   * designing date masks (e.g. `[1-12]/[1-31]/9999`).
   */
  internal fun compile(mask: String): CompiledMask {
    val slots = mutableListOf<Slot>()
    val expanded = StringBuilder()
    var i = 0

    while (i < mask.length) {
      if (mask[i] == '[') {
        val closeIdx = mask.indexOf(']', i)
        if (closeIdx == -1) {
          // Malformed — treat '[' as a literal and advance past it.
          slots.add(Slot.Literal('['))
          expanded.append('[')
          i++
          continue
        }
        val content = mask.substring(i + 1, closeIdx) // e.g. "1-12"
        val dashIdx = content.indexOf('-')
        val from = if (dashIdx > 0) content.substring(0, dashIdx).toIntOrNull() else null
        val to = if (dashIdx > 0) content.substring(dashIdx + 1).toIntOrNull() else null
        if (from != null && to != null) {
          val length = maxOf(from.toString().length, to.toString().length)
          repeat(length) {
            slots.add(Slot.RangeSlot(content, length, from, to))
            expanded.append('9')
          }
        } else {
          // Malformed range — emit the entire "[...]" as individual literals.
          val literal = "[$content]"
          for (c in literal) { slots.add(Slot.Literal(c)); expanded.append(c) }
        }
        i = closeIdx + 1
      } else {
        when (val ch = mask[i]) {
          '9' -> { slots.add(Slot.Digit);  expanded.append('9') }
          'A' -> { slots.add(Slot.Letter); expanded.append('A') }
          '*' -> { slots.add(Slot.Any);    expanded.append('*') }
          else -> { slots.add(Slot.Literal(ch)); expanded.append(ch) }
        }
        i++
      }
    }

    return CompiledMask(slots, expanded.toString())
  }

  // -------------------------------------------------------------------------
  // apply
  // -------------------------------------------------------------------------

  internal fun apply(input: String, compiled: CompiledMask): Pair<String, String> {
    if (compiled.slots.isEmpty()) return Pair(input, input)

    val masked = StringBuilder()
    val raw = StringBuilder()
    val slots = compiled.slots

    // Accumulate per-block digit strings so we can validate range prefixes
    val blockPartials = mutableMapOf<String, StringBuilder>()

    var ii = 0   // index into input characters
    var si = 0   // index into slots

    while (si < slots.size && ii < input.length) {
      val slot = slots[si]
      val c = input[ii]

      when (slot) {
        is Slot.Digit -> {
          if (c.isDigit()) {
            masked.append(c); raw.append(c); ii++; si++
          } else {
            ii++
          }
        }

        is Slot.Letter -> {
          if (c.isLetter()) {
            masked.append(c); raw.append(c); ii++; si++
          } else {
            ii++
          }
        }

        is Slot.Any -> {
          if (c.isLetterOrDigit()) {
            masked.append(c); raw.append(c); ii++; si++
          } else {
            ii++
          }
        }

        is Slot.Literal -> {
          masked.append(slot.char)
          if (c == slot.char) ii++
          si++
        }

        is Slot.RangeSlot -> {
          if (c.isDigit()) {
            val partial = blockPartials.getOrPut(slot.blockName) { StringBuilder() }
            val candidate = partial.toString() + c
            if (isValidPrefix(candidate, slot.from, slot.to, slot.length)) {
              partial.append(c)
              masked.append(c)
              raw.append(c)
              ii++
              si++
            } else {
              // Invalid digit for this range position — skip the input char
              ii++
            }
          } else {
            // Non-digit where a range digit is expected — skip
            ii++
          }
        }
      }
    }

    return Pair(masked.toString(), raw.toString())
  }

  // -------------------------------------------------------------------------
  // extractRaw
  // -------------------------------------------------------------------------

  internal fun extractRaw(text: String, compiled: CompiledMask): String {
    return extractRaw(text, compiled.expandedMask)
  }

  private fun extractRaw(text: String, expandedMask: String): String {
    val raw = StringBuilder()
    val textChars = text.toList()
    val maskChars = expandedMask.toList()
    var ti = 0
    var mi = 0

    while (ti < textChars.size && mi < maskChars.size) {
      val m = maskChars[mi]
      if (m == '9' || m == 'A' || m == '*') {
        raw.append(textChars[ti])
        ti++
        mi++
      } else {
        if (textChars[ti] == m) ti++
        mi++
      }
    }

    return raw.toString()
  }

  // -------------------------------------------------------------------------
  // isValidPrefix
  // -------------------------------------------------------------------------

  /**
   * Returns true if [partial] (the digits entered so far for a range block) is
   * still consistent with producing a final value inside [from]..[to].
   *
   * After [partial] the remaining positions can be filled with '0'..'9', so we
   * test whether the optimistic interval [min, max] overlaps [from, to].
   */
  private fun isValidPrefix(partial: String, from: Int, to: Int, length: Int): Boolean {
    val remaining = length - partial.length
    val partialMin = (partial + "0".repeat(remaining)).toIntOrNull() ?: return false
    val partialMax = (partial + "9".repeat(remaining)).toIntOrNull() ?: return false
    return partialMin <= to && partialMax >= from
  }
}
