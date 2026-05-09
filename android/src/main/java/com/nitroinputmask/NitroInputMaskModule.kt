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

  override fun attach(nativeID: String, mask: String) {
    attemptAttach(nativeID, mask, ATTACH_RETRIES)
  }

  private fun attemptAttach(nativeID: String, mask: String, retries: Int) {
    val context = NitroInputMaskContext.reactContext ?: return
    context.currentActivity?.runOnUiThread {
      val root = context.currentActivity?.window?.decorView ?: return@runOnUiThread
      val editText = findEditText(root, nativeID)
      if (editText != null) {
        val watcher = NitroInputMaskTextWatcher(mask, editText)
        states[nativeID] = MaskState(WeakReference(editText), watcher)
        insertWatcherFirst(editText, watcher)
      } else if (retries > 0) {
        Handler(Looper.getMainLooper()).postDelayed(
          { attemptAttach(nativeID, mask, retries - 1) },
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

  override fun updateMask(nativeID: String, mask: String) {
    states[nativeID]?.watcher?.mask = mask
  }

  override fun setValue(nativeID: String, rawValue: String) {
    val state = states[nativeID] ?: return
    val editText = state.editTextRef.get() ?: return
    val (masked, _) = MaskEngine.apply(rawValue, state.watcher.mask)
    NitroInputMaskContext.reactContext?.currentActivity?.runOnUiThread {
      state.watcher.isProgrammatic = true
      editText.setText(masked)
      editText.setSelection(editText.text.length)
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
