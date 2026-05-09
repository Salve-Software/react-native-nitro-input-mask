import UIKit

class NitroInputMaskDelegateProxy: NSObject, UITextFieldDelegate {
  var mask: String
  weak var original: UITextFieldDelegate?

  init(mask: String, original: UITextFieldDelegate?) {
    self.mask = mask
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

    if mask.isEmpty {
      textField.text = proposed
      textField.sendActions(for: .editingChanged)
      return false
    }

    let isDeletion = string.isEmpty
    var (masked, _) = MaskEngine.apply(input: proposed, mask: mask)

    // When deleting a separator, the mask re-inserts it, yielding the same text.
    // Drop the last raw digit to actually move the cursor back.
    if isDeletion && masked == current {
      let raw = MaskEngine.extractRaw(from: current, mask: mask)
      if !raw.isEmpty {
        (masked, _) = MaskEngine.apply(input: String(raw.dropLast()), mask: mask)
      }
    }

    textField.text = masked
    CursorEngine.apply(to: textField, masked: masked, mask: mask)
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
