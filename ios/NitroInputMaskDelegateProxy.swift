import UIKit

class NitroInputMaskDelegateProxy: NSObject, UITextFieldDelegate {
  var engine: MaskEngineProtocol
  weak var original: UITextFieldDelegate?

  init(engine: MaskEngineProtocol, original: UITextFieldDelegate?) {
    self.engine = engine
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

    let isDeletion = string.isEmpty
    var (masked, raw) = engine.apply(input: proposed)

    // Empty mask (custom with no mask string) — pass through
    if masked.isEmpty && raw.isEmpty && !proposed.isEmpty {
      let (_, currentRaw) = engine.apply(input: current)
      if currentRaw.isEmpty {
        textField.text = proposed
        textField.sendActions(for: .editingChanged)
        return false
      }
    }

    // Separator deletion: masking re-produces the same text because the separator
    // is always re-inserted. If there is data, block the deletion (text unchanged,
    // cursor stays at the separator). If there is no data, clear the field.
    if isDeletion && masked == current {
      let (_, extractedRaw) = engine.apply(input: current)
      masked = extractedRaw.isEmpty ? "" : current
    }

    textField.text = masked

    if engine.wantsTrailingCursor {
      // Money and similar: always place cursor at end of field
      let endPos = masked.count
      if let pos = textField.position(from: textField.beginningOfDocument, offset: endPos) {
        textField.selectedTextRange = textField.textRange(from: pos, to: pos)
      }
    } else if let expandedMask = engine.expandedMask {
      let cursorOffset: Int
      if isDeletion {
        cursorOffset = min(range.location, masked.count)
      } else {
        cursorOffset = CursorEngine.offsetAfterInsertion(
          oldMasked: current,
          newMasked: masked,
          mask: expandedMask,
          at: range.location
        )
      }
      if let pos = textField.position(from: textField.beginningOfDocument, offset: cursorOffset) {
        textField.selectedTextRange = textField.textRange(from: pos, to: pos)
      }
    } else {
      // Fallback: put cursor at end
      let endPos = masked.count
      if let pos = textField.position(from: textField.beginningOfDocument, offset: endPos) {
        textField.selectedTextRange = textField.textRange(from: pos, to: pos)
      }
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
