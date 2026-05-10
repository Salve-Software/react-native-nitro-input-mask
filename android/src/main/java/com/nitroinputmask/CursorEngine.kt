package com.nitroinputmask

object CursorEngine {
  fun offsetAtEnd(masked: String, mask: String): Int {
    for (i in masked.length - 1 downTo 0) {
      if (i < mask.length && (mask[i] == '9' || mask[i] == 'A' || mask[i] == '*')) {
        return i + 1
      }
    }
    return masked.length
  }

  fun offsetAfterInsertion(oldMasked: String, newMasked: String, mask: String, at: Int): Int {
    var dataRankBefore = 0
    for (i in 0 until minOf(at, mask.length)) {
      val m = mask[i]
      if (m == '9' || m == 'A' || m == '*') dataRankBefore++
    }
    val targetRank = dataRankBefore + 1
    var dataCount = 0
    for (i in 0 until minOf(newMasked.length, mask.length)) {
      val m = mask[i]
      if (m == '9' || m == 'A' || m == '*') {
        dataCount++
        if (dataCount == targetRank) return i + 1
      }
    }
    return newMasked.length
  }
}
