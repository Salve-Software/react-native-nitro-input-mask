import UIKit

enum CursorEngine {
  static func offset(masked: String, mask: String) -> Int {
    let maskChars = Array(mask)
    var result = masked.count
    for i in stride(from: min(masked.count, mask.count) - 1, through: 0, by: -1) {
      let m = maskChars[i]
      if m == "9" || m == "A" || m == "*" { result = i + 1; break }
    }
    return result
  }

  static func apply(to textField: UITextField, masked: String, mask: String) {
    let off = offset(masked: masked, mask: mask)
    guard let pos = textField.position(from: textField.beginningOfDocument, offset: off) else { return }
    textField.selectedTextRange = textField.textRange(from: pos, to: pos)
  }
}
