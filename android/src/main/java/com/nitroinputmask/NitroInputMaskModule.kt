package com.nitroinputmask

import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.TextView
import androidx.annotation.Keep
import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.nitroinputmask.HybridNitroInputMaskSpec
import com.margelo.nitro.nitroinputmask.NitroMaskOptions
import java.lang.ref.WeakReference

private const val ATTACH_RETRIES = 5
private const val ATTACH_RETRY_DELAY_MS = 50L

@Keep
@DoNotStrip
class HybridNitroInputMaskModule : HybridNitroInputMaskSpec() {
  private data class MaskState(
    val editTextRef: WeakReference<EditText>,
    val watcher: NitroInputMaskTextWatcher
  )

  private val states = mutableMapOf<String, MaskState>()

  override fun attach(nativeID: String, maskType: String, options: NitroMaskOptions) {
    val engine = MaskEngineFactory.build(maskType, options)
    attemptAttach(nativeID, engine, ATTACH_RETRIES)
  }

  private fun attemptAttach(nativeID: String, engine: MaskEngineProtocol, retries: Int) {
    val context = NitroInputMaskContext.reactContext ?: return
    context.currentActivity?.runOnUiThread {
      val root = context.currentActivity?.window?.decorView ?: return@runOnUiThread
      val editText = findEditText(root, nativeID)
      if (editText != null) {
        val watcher = NitroInputMaskTextWatcher(engine, editText)
        states[nativeID] = MaskState(WeakReference(editText), watcher)
        insertWatcherFirst(editText, watcher)
      } else if (retries > 0) {
        Handler(Looper.getMainLooper()).postDelayed(
          { attemptAttach(nativeID, engine, retries - 1) },
          ATTACH_RETRY_DELAY_MS
        )
      }
    }
  }

  override fun detach(nativeID: String) {
    val state = states.remove(nativeID) ?: return
    NitroInputMaskContext.reactContext?.currentActivity?.runOnUiThread {
      state.editTextRef.get()?.removeTextChangedListener(state.watcher)
    }
  }

  override fun updateMask(nativeID: String, maskType: String, options: NitroMaskOptions) {
    val engine = MaskEngineFactory.build(maskType, options)
    states[nativeID]?.watcher?.engine = engine
  }

  override fun setValue(nativeID: String, rawValue: String) {
    val state = states[nativeID] ?: return
    val editText = state.editTextRef.get() ?: return
    val (masked, _) = state.watcher.engine.apply(rawValue)
    NitroInputMaskContext.reactContext?.currentActivity?.runOnUiThread {
      if (editText.text.toString() == masked) return@runOnUiThread
      state.watcher.isProgrammatic = true
      editText.setText(masked)
      if (state.watcher.engine.wantsTrailingCursor) {
        editText.setSelection(editText.text.length)
      } else {
        editText.setSelection(editText.text.length)
      }
      state.watcher.isProgrammatic = false
    }
  }

  private fun findEditText(root: View, nativeID: String): EditText? {
    val tag = root.getTag(com.facebook.react.R.id.view_tag_native_id)
    if (root is EditText && tag == nativeID) return root
    if (root is ViewGroup) {
      for (i in 0 until root.childCount) {
        findEditText(root.getChildAt(i), nativeID)?.let { return it }
      }
    }
    return null
  }

  @Suppress("UNCHECKED_CAST")
  private fun insertWatcherFirst(editText: EditText, watcher: NitroInputMaskTextWatcher) {
    // Insert at index 0 so our watcher runs before React Native's own TextWatcher,
    // ensuring the mask is applied before RN reads the new text.
    try {
      val field = TextView::class.java.getDeclaredField("mListeners")
      field.isAccessible = true
      val listeners = field.get(editText) as? ArrayList<android.text.TextWatcher>
      if (listeners != null) {
        listeners.add(0, watcher)
        return
      }
    } catch (_: Exception) {}
    editText.addTextChangedListener(watcher)
  }
}
