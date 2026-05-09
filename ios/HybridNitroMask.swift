import UIKit
import NitroModules

class HybridNitroMask: HybridNitroMaskSpec {
  private let textField = UITextField()
  private let tfDelegate = NitroMaskTextFieldDelegate()

  var view: UIView { textField }

  var mask: String = "" {
    didSet {
      let raw = MaskEngine.extractRaw(from: textField.text ?? "", mask: oldValue)
      textField.text = MaskEngine.apply(input: raw, mask: mask).masked
    }
  }

  var value: String = "" {
    didSet {
      let currentRaw = MaskEngine.extractRaw(from: textField.text ?? "", mask: mask)
      guard value != currentRaw else { return }
      textField.text = MaskEngine.apply(input: value, mask: mask).masked
    }
  }

  var onChangeText: ((_ maskedValue: String, _ rawValue: String) -> Void)? = nil

  override init() {
    super.init()
    tfDelegate.owner = self
    textField.delegate = tfDelegate
    textField.borderStyle = .none
  }

  func handleTextChange(
    _ textField: UITextField,
    range: NSRange,
    replacement string: String
  ) -> Bool {
    let current = textField.text ?? ""
    guard let swiftRange = Range(range, in: current) else { return false }
    let proposed = current.replacingCharacters(in: swiftRange, with: string)

    if mask.isEmpty {
      textField.text = proposed
      onChangeText?(proposed, proposed)
      return false
    }

    let isDeletion = string.isEmpty
    var (masked, raw) = MaskEngine.apply(input: proposed, mask: mask)

    if isDeletion && masked == current {
      let currentRaw = MaskEngine.extractRaw(from: current, mask: mask)
      if !currentRaw.isEmpty {
        (masked, raw) = MaskEngine.apply(input: String(currentRaw.dropLast()), mask: mask)
      }
    }

    textField.text = masked
    placeCursor(in: textField, maskedText: masked)
    onChangeText?(masked, raw)
    return false
  }

  private func placeCursor(in textField: UITextField, maskedText: String) {
    let maskChars = Array(mask)
    let maskedChars = Array(maskedText)
    var cursorOffset = maskedText.count
    
    for i in stride(from: maskedChars.count - 1, through: 0, by: -1) {
      if i < maskChars.count {
        let m = maskChars[i]
        if m == "9" || m == "A" || m == "*" {
          cursorOffset = i + 1
          break
        }
      }
    }
    
    if let pos = textField.position(from: textField.beginningOfDocument, offset: cursorOffset) {
      textField.selectedTextRange = textField.textRange(from: pos, to: pos)
    }
  }
}
