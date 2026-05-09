package com.nitromask

import android.text.Editable
import android.text.TextWatcher
import android.widget.EditText
import androidx.annotation.Keep
import com.facebook.proguard.annotations.DoNotStrip
import com.facebook.react.uimanager.ThemedReactContext
import com.margelo.nitro.nitromask.HybridNitroMaskSpec

@Keep
@DoNotStrip
class HybridNitroMask(val context: ThemedReactContext) : HybridNitroMaskSpec() {
    // View
    private val editText = EditText(context).apply { background = null }
    override val view = editText

    // Guard flag to prevent infinite TextWatcher loop
    private var isProgrammatic = false

    // Props
    private var _mask: String = ""
    override var mask: String
        get() = _mask
        set(value) {
            _mask = value
            val (masked, _) = applyMask(editText.text.toString(), _mask)
            isProgrammatic = true
            editText.setText(masked)
            isProgrammatic = false
        }

    private var _value: String = ""
    override var value: String
        get() = _value
        set(v) {
            _value = v
            if (_value == editText.text.toString()) return
            val (masked, _) = applyMask(_value, _mask)
            isProgrammatic = true
            editText.setText(masked)
            isProgrammatic = false
        }

    override var onChangeText: (maskedValue: String, rawValue: String) -> Unit = { _, _ -> }

    init {
        editText.addTextChangedListener(object : TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                if (isProgrammatic) return
                val input = s?.toString() ?: ""
                if (_mask.isEmpty()) {
                    onChangeText(input, input)
                    return
                }
                val (masked, raw) = applyMask(input, _mask)
                if (masked == input) {
                    onChangeText(masked, raw)
                } else {
                    isProgrammatic = true
                    s?.replace(0, s.length, masked)
                    isProgrammatic = false
                    onChangeText(masked, raw)
                }
            }
        })
    }

    companion object {
        fun applyMask(input: String, mask: String): Pair<String, String> {
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
                            masked.append(c)
                            raw.append(c)
                            ii++
                        } else {
                            ii++
                            continue
                        }
                    }
                    'A' -> {
                        if (c.isLetter()) {
                            masked.append(c)
                            raw.append(c)
                            ii++
                        } else {
                            ii++
                            continue
                        }
                    }
                    '*' -> {
                        if (c.isLetterOrDigit()) {
                            masked.append(c)
                            raw.append(c)
                            ii++
                        } else {
                            ii++
                            continue
                        }
                    }
                    else -> {
                        // Literal character — auto-insert
                        masked.append(m)
                        // Consume input char if it matches the literal (paste handling)
                        if (c == m) {
                            ii++
                        }
                    }
                }
                mi++
            }

            return Pair(masked.toString(), raw.toString())
        }
    }
}
