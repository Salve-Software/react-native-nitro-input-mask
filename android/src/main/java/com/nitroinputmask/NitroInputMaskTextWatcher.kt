package com.nitroinputmask

import android.text.Editable
import android.text.TextWatcher
import android.widget.EditText
import java.lang.ref.WeakReference

// Weak reference avoids EditText → TextWatcher → EditText retain cycle
internal class NitroInputMaskTextWatcher(var engine: MaskEngineProtocol, editText: EditText) : TextWatcher {
  private val editTextRef = WeakReference(editText)
  var isProgrammatic = false
  private var prevLength = 0
  private var isDeletion = false
  private var changeStart = 0
  private var prevMasked = ""
  private var prevCursorEnd = 0

  override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
    prevLength = s?.length ?: 0
    isDeletion = after < count
    prevMasked = s?.toString() ?: ""
    prevCursorEnd = start + count
  }

  override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
    changeStart = start
  }

  override fun afterTextChanged(s: Editable?) {
    if (isProgrammatic) return
    val editText = editTextRef.get() ?: return
    val input = s?.toString()?.replace("\n", "") ?: ""

    var (masked, _) = engine.apply(input)

    // Separator deletion: masking re-produces the same text because the separator
    // is always re-inserted. If there is data, block the deletion (text unchanged,
    // cursor moves to just before the separator). If there is no data, clear the field.
    var isSeparatorDeletion = false
    if (isDeletion && masked == prevMasked) {
      val (_, raw) = engine.apply(input)
      if (raw.isEmpty()) {
        masked = ""
      } else {
        isSeparatorDeletion = true
        // masked stays == prevMasked; cursor will move to changeStart below
      }
    }

    val cursorPos = when {
      engine.wantsTrailingCursor -> when {
        isSeparatorDeletion -> changeStart
        isDeletion -> positionAfterDigits(prevMasked.take(changeStart).count { it.isDigit() }, masked)
        else -> {
          val digitsAfter = countDigits(prevMasked, prevCursorEnd)
          cursorPositionWithDigitsAfter(digitsAfter, masked)
        }
      }
      isDeletion -> minOf(changeStart, masked.length)
      else -> {
        val expMask = engine.expandedMask
        if (expMask != null) {
          val raw = CursorEngine.offsetAfterInsertion(prevMasked, masked, expMask, changeStart)
          skipLeadingLiterals(raw, masked, expMask)
        } else {
          masked.length
        }
      }
    }

    if (masked == s?.toString()) {
      editText.setSelection(cursorPos)
    } else {
      isProgrammatic = true
      s?.replace(0, s.length, masked)
      isProgrammatic = false
      editText.setSelection(minOf(cursorPos, editText.text.length))
    }
  }

  private fun positionAfterDigits(count: Int, text: String): Int {
    if (count == 0) return text.indexOfFirst { it.isDigit() }.takeIf { it >= 0 } ?: 0
    var found = 0
    for (i in text.indices) {
      if (text[i].isDigit()) {
        found++
        if (found == count) return i + 1
      }
    }
    return text.length
  }

  private fun skipLeadingLiterals(offset: Int, masked: String, mask: String): Int {
    val dataTokens = setOf('9', 'A', '*')
    var idx = offset
    while (idx < mask.length && mask[idx] !in dataTokens) idx++
    return minOf(idx, masked.length)
  }

  private fun countDigits(text: String, from: Int): Int {
    if (from >= text.length) return 0
    return text.substring(from).count { it.isDigit() }
  }

  private fun cursorPositionWithDigitsAfter(count: Int, text: String): Int {
    if (count == 0) return text.length
    var digitsFromEnd = 0
    var pos = text.length
    while (pos > 0) {
      pos--
      if (text[pos].isDigit()) {
        digitsFromEnd++
        if (digitsFromEnd == count) return pos
      }
    }
    return 0
  }
}
