package com.nitroinputmask

import android.text.Editable
import android.text.TextWatcher
import android.widget.EditText
import java.lang.ref.WeakReference

// Weak reference avoids EditText → TextWatcher → EditText retain cycle
internal class NitroInputMaskTextWatcher(var compiled: CompiledMask, editText: EditText) : TextWatcher {
  private val editTextRef = WeakReference(editText)
  var isProgrammatic = false
  private var prevLength = 0
  private var isDeletion = false
  private var changeStart = 0
  private var prevMasked = ""

  override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
    prevLength = s?.length ?: 0
    isDeletion = after < count
    prevMasked = s?.toString() ?: ""
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

    // Separator deletion: masking re-produces the same text because the separator
    // is always re-inserted. If there is data, block the deletion (text unchanged,
    // cursor stays at the separator). If there is no data, clear the field.
    if (isDeletion && masked == prevMasked) {
      val raw = MaskEngine.extractRaw(input, compiled)
      masked = if (raw.isEmpty()) "" else prevMasked
    }

    val cursorPos = if (isDeletion) {
      minOf(changeStart, masked.length)
    } else {
      CursorEngine.offsetAfterInsertion(prevMasked, masked, compiled.expandedMask, changeStart)
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
