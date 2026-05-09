package com.nitromask

import android.text.Editable
import android.text.TextWatcher
import java.lang.ref.WeakReference

// Weak reference mirrors iOS delegate pattern: avoids HybridNitroMask → EditText → TextWatcher → HybridNitroMask retain cycle
class NitroMaskTextWatcher(owner: HybridNitroMask) : TextWatcher {
  private val ownerRef = WeakReference(owner)
  private var prevLength = 0
  private var isDeletion = false

  override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
    prevLength = s?.length ?: 0
    isDeletion = after < count
  }

  override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}

  override fun afterTextChanged(s: Editable?) {
    ownerRef.get()?.handleTextChange(s, isDeletion, prevLength)
  }
}
