import UIKit

class NitroInputMaskDelegateProxy: NSObject, UITextFieldDelegate {
  var compiled: CompiledMask
  weak var original: UITextFieldDelegate?

  init(compiled: CompiledMask, original: UITextFieldDelegate?) {
    self.compiled = compiled
    self.original = original
  }

  func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    let current = textField.text ?? ""
    guard let swiftRange = Range(range, in: current) else { return false }
    let proposed = current.replacingCharacters(in: swiftRange, with: string)

    if compiled.isEmpty {
      textField.text = proposed
      textField.sendActions(for: .editingChanged)
      return false
    }

    let isDeletion = string.isEmpty
    var (masked, _) = MaskEngine.apply(input: proposed, compiled: compiled)

    // When deleting a separator, the mask re-inserts it, yielding the same text.
    // Drop the last raw digit to actually move the cursor back.
    if isDeletion && masked == current {
      let raw = MaskEngine.extractRaw(from: current, compiled: compiled)
      if !raw.isEmpty {
        (masked, _) = MaskEngine.apply(input: String(raw.dropLast()), compiled: compiled)
      }
    }

    textField.text = masked
    if isDeletion {
      let offset = min(range.location, masked.count)
      if let pos = textField.position(from: textField.beginningOfDocument, offset: offset) {
        textField.selectedTextRange = textField.textRange(from: pos, to: pos)
      }
    } else {
      CursorEngine.apply(to: textField, masked: masked, mask: compiled.expandedMask)
    }
    textField.sendActions(for: .editingChanged)
    return false
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return original?.textFieldShouldReturn?(textField) ?? true
  }

  override func responds(to aSelector: Selector!) -> Bool {
    super.responds(to: aSelector) || (original?.responds(to: aSelector) ?? false)
  }

  override func forwardingTarget(for aSelector: Selector!) -> Any? {
    if original?.responds(to: aSelector) == true { return original }
    return super.forwardingTarget(for: aSelector)
  }
}
