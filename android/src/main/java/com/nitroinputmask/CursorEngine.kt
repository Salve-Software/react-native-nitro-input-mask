package com.nitroinputmask

object CursorEngine {
  fun offset(masked: String, mask: String): Int {
    for (i in masked.length - 1 downTo 0) {
      if (i < mask.length && (mask[i] == '9' || mask[i] == 'A' || mask[i] == '*')) {
        return i + 1
      }
    }
    return masked.length
  }
}
