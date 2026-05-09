package com.nitroinputmask

import android.text.Editable
import android.text.TextWatcher
import android.widget.EditText
import java.lang.ref.WeakReference

// Weak reference avoids EditText → TextWatcher → EditText retain cycle
class NitroInputMaskTextWatcher(var compiled: CompiledMask, editText: EditText) : TextWatcher {
  private val editTextRef = WeakReference(editText)
  var isProgrammatic = false
  private var prevLength = 0
  private var isDeletion = false
  private var changeStart = 0

  override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
    prevLength = s?.length ?: 0
    isDeletion = after < count
  }

  override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
    changeStart = start
  }

  override fun afterTextChanged(s: Editable?) {
    if (isProgrammatic) return
    val editText = editTextRef.get() ?: return
    val input = s?.toString()?.replace("\n", "") ?: ""
    if (compiled.isEmpty) return

    var (masked, _) = MaskEngine.apply(input, compiled)

    // When deleting a separator, the mask re-inserts it, yielding the same length.
    // Drop the last raw digit to actually move the cursor back.
    if (isDeletion && masked.length == prevLength) {
      val raw = MaskEngine.extractRaw(input, compiled)
      if (raw.isNotEmpty()) {
        masked = MaskEngine.apply(raw.dropLast(1), compiled).first
      }
    }

    val cursorPos = if (isDeletion) {
      minOf(changeStart, masked.length)
    } else {
      CursorEngine.offset(masked, compiled.expandedMask)
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
}
