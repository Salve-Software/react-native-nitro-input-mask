package com.nitromask

import android.text.Editable
import android.widget.EditText
import androidx.annotation.Keep
import com.facebook.proguard.annotations.DoNotStrip
import com.facebook.react.uimanager.ThemedReactContext
import com.margelo.nitro.nitromask.HybridNitroMaskSpec

@Keep
@DoNotStrip
class HybridNitroMask(val context: ThemedReactContext) : HybridNitroMaskSpec() {
  private val editText = EditText(context).apply { background = null }
  override val view = editText

  @Volatile
  internal var isProgrammatic = false

  private var _mask: String = ""
  override var mask: String
    get() = _mask
    set(value) {
      val raw = MaskEngine.extractRaw(editText.text.toString(), _mask)
      _mask = value
      val (masked, _) = MaskEngine.apply(raw, _mask)
      isProgrammatic = true
      editText.setText(masked)
      isProgrammatic = false
    }

  private var _value: String = ""
  override var value: String
    get() = _value
    set(v) {
      _value = v
      val currentRaw = MaskEngine.extractRaw(editText.text.toString(), _mask)
      if (_value == currentRaw) return
      val (masked, _) = MaskEngine.apply(_value, _mask)
      isProgrammatic = true
      editText.setText(masked)
      isProgrammatic = false
    }

  override var onChangeText: ((maskedValue: String, rawValue: String) -> Unit)? = null

  init {
    editText.addTextChangedListener(NitroMaskTextWatcher(this))
  }

  internal fun handleTextChange(s: Editable?, isDeletion: Boolean, prevLength: Int) {
    if (isProgrammatic) return
    val input = s?.toString() ?: ""

    if (_mask.isEmpty()) {
      onChangeText?.invoke(input, input)
      return
    }

    var (masked, raw) = MaskEngine.apply(input, _mask)

    if (isDeletion && masked.length >= prevLength) {
      val currentRaw = MaskEngine.extractRaw(input, _mask)
      if (currentRaw.isNotEmpty()) {
        val (newMasked, newRaw) = MaskEngine.apply(currentRaw.dropLast(1), _mask)
        masked = newMasked
        raw = newRaw
      }
    }

    if (masked == s?.toString()) {
      editText.setSelection(lastUserCharPos(masked, _mask))
      onChangeText?.invoke(masked, raw)
    }
    else {
      isProgrammatic = true
      s?.replace(0, s.length, masked)
      isProgrammatic = false
      editText.setSelection(minOf(lastUserCharPos(masked, _mask), editText.text.length))
      onChangeText?.invoke(masked, raw)
    }
  }

  private fun lastUserCharPos(masked: String, mask: String): Int {
    val maskChars = mask.toList()

    for (i in masked.length - 1 downTo 0) {
      if (i < maskChars.size) {
        val m = maskChars[i]
        if (m == '9' || m == 'A' || m == '*') return i + 1
      }
    }

    return masked.length
  }
}
