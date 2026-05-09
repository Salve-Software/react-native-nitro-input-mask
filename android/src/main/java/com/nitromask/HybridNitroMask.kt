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
    @Volatile private var isProgrammatic = false

    // Props
    private var _mask: String = ""
    override var mask: String
        get() = _mask
        set(value) {
            val raw = extractRaw(editText.text.toString(), _mask)
            _mask = value
            val (masked, _) = applyMask(raw, _mask)
            isProgrammatic = true
            editText.setText(masked)
            isProgrammatic = false
        }

    private var _value: String = ""
    override var value: String
        get() = _value
        set(v) {
            _value = v
            val currentRaw = extractRaw(editText.text.toString(), _mask)
            if (_value == currentRaw) return
            val (masked, _) = applyMask(_value, _mask)
            isProgrammatic = true
            editText.setText(masked)
            isProgrammatic = false
        }

    override var onChangeText: ((maskedValue: String, rawValue: String) -> Unit)? = null

    init {
        editText.addTextChangedListener(object : TextWatcher {
            private var prevLength = 0
            private var isDeletion = false

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
                prevLength = s?.length ?: 0
                isDeletion = after < count
            }
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: Editable?) {
                if (isProgrammatic) return
                val input = s?.toString() ?: ""
                if (_mask.isEmpty()) {
                    onChangeText?.invoke(input, input)
                    return
                }
                var (masked, raw) = applyMask(input, _mask)

                // Issue 10: backspace on literal — re-inserted same text, strip one raw char
                if (isDeletion && masked.length >= prevLength) {
                    val currentRaw = extractRaw(input, _mask)
                    if (currentRaw.isNotEmpty()) {
                        val trimmedRaw = currentRaw.dropLast(1)
                        val (newMasked, newRaw) = applyMask(trimmedRaw, _mask)
                        masked = newMasked
                        raw = newRaw
                    }
                }

                if (masked == s?.toString()) {
                    // Issue 4/5: place cursor after last user-typed char
                    val cursorPos = lastUserCharPos(masked, _mask)
                    editText.setSelection(cursorPos)
                    onChangeText?.invoke(masked, raw)
                } else {
                    isProgrammatic = true
                    s?.replace(0, s.length, masked)
                    isProgrammatic = false
                    // Issue 4/5: place cursor after last user-typed char
                    val cursorPos = lastUserCharPos(masked, _mask)
                    editText.setSelection(minOf(cursorPos, editText.text.length))
                    onChangeText?.invoke(masked, raw)
                }
            }
        })
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

    companion object {
        fun extractRaw(text: String, mask: String): String {
            val raw = StringBuilder()
            val textChars = text.toList()
            val maskChars = mask.toList()
            var ti = 0
            var mi = 0
            while (ti < textChars.size && mi < maskChars.size) {
                val m = maskChars[mi]
                val t = textChars[ti]
                if (m == '9' || m == 'A' || m == '*') {
                    raw.append(t)
                    ti++
                    mi++
                } else {
                    // literal — only consume text char if it matches
                    if (t == m) ti++
                    mi++
                }
            }
            return raw.toString()
        }

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
