import UIKit

// Separate NSObject subclass required because HybridNitroMaskSpec_base does not inherit NSObject
class NitroMaskTextFieldDelegate: NSObject, UITextFieldDelegate {
  weak var owner: HybridNitroMask?

  func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    owner?.handleTextChange(textField, range: range, replacement: string) ?? true
  }
}
