package com.nitroinputmask

import android.text.Editable
import android.text.TextWatcher
import android.widget.EditText
import java.lang.ref.WeakReference

// Weak reference avoids EditText → TextWatcher → EditText retain cycle
class NitroInputMaskTextWatcher(var mask: String, editText: EditText) : TextWatcher {
  private val editTextRef = WeakReference(editText)
  var isProgrammatic = false
  private var prevLength = 0
  private var isDeletion = false

  override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
    prevLength = s?.length ?: 0
    isDeletion = after < count
  }

  override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}

  override fun afterTextChanged(s: Editable?) {
    if (isProgrammatic) return
    val editText = editTextRef.get() ?: return
    val input = s?.toString()?.replace("\n", "") ?: ""
    if (mask.isEmpty()) return

    var (masked, _) = MaskEngine.apply(input, mask)

    // When deleting a separator, the mask re-inserts it, yielding the same length.
    // Drop the last raw digit to actually move the cursor back.
    if (isDeletion && masked.length == prevLength) {
      val raw = MaskEngine.extractRaw(input, mask)
      if (raw.isNotEmpty()) {
        masked = MaskEngine.apply(raw.dropLast(1), mask).first
      }
    }

    if (masked == s?.toString()) {
      editText.setSelection(CursorEngine.offset(masked, mask))
    } else {
      isProgrammatic = true
      s?.replace(0, s.length, masked)
      isProgrammatic = false
      editText.setSelection(minOf(CursorEngine.offset(masked, mask), editText.text.length))
    }
  }
}
