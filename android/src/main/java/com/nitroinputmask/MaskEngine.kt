package com.nitroinputmask

object MaskEngine {
  fun apply(input: String, mask: String): Pair<String, String> {
    if (mask.isEmpty()) return Pair(input, input)

    val masked = StringBuilder()
    val raw = StringBuilder()
    val inputChars = input.toList()
    val maskChars = mask.toList()
    var ii = 0
    var mi = 0

    while (mi < maskChars.size && ii < inputChars.size) {
      val m = maskChars[mi]
      val c = inputChars[ii]

      when (m) {
        '9' -> {
          if (c.isDigit()) {
            masked.append(c); raw.append(c); ii++
          }
          else {
            ii++; continue
          }
        }

        'A' -> {
          if (c.isLetter()) {
            masked.append(c); raw.append(c); ii++
          }
          else {
            ii++; continue
          }
        }

        '*' -> {
          if (c.isLetterOrDigit()) {
            masked.append(c); raw.append(c); ii++
          }
          else {
            ii++; continue
          }
        }

        else -> {
          masked.append(m)
          if (c == m) ii++
        }
      }
      mi++
    }

    return Pair(masked.toString(), raw.toString())
  }

  fun extractRaw(text: String, mask: String): String {
    val raw = StringBuilder()
    val textChars = text.toList()
    val maskChars = mask.toList()
    var ti = 0
    var mi = 0

    while (ti < textChars.size && mi < maskChars.size) {
      val m = maskChars[mi]
      if (m == '9' || m == 'A' || m == '*') {
        raw.append(textChars[ti])
        ti++
        mi++
      }
      else {
        if (textChars[ti] == m) ti++
        mi++
      }
    }

    return raw.toString()
  }
}
