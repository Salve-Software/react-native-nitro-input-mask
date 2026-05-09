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

    // Separator deletion: masking re-produces the same text because the separator
    // is always re-inserted. If there is data, block the deletion (text unchanged,
    // cursor stays at the separator). If there is no data, clear the field.
    if isDeletion && masked == current {
      let raw = MaskEngine.extractRaw(from: current, compiled: compiled)
      masked = raw.isEmpty ? "" : current
    }

    textField.text = masked
    let cursorOffset: Int
    if isDeletion {
      cursorOffset = min(range.location, masked.count)
    } else {
      cursorOffset = CursorEngine.offsetAfterInsertion(
        oldMasked: current,
        newMasked: masked,
        mask: compiled.expandedMask,
        at: range.location
      )
    }
    if let pos = textField.position(from: textField.beginningOfDocument, offset: cursorOffset) {
      textField.selectedTextRange = textField.textRange(from: pos, to: pos)
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
