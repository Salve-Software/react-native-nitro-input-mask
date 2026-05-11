import UIKit

enum CursorEngine {
  static func offsetAtEnd(masked: String, mask: String) -> Int {
    let maskChars = Array(mask)
    var result = masked.count
    for i in stride(from: min(masked.count, mask.count) - 1, through: 0, by: -1) {
      let m = maskChars[i]
      if m == "9" || m == "A" || m == "*" {
        result = i + 1
        break
      }
    }
    return result
  }

  /// Returns the cursor offset after inserting one character at `insertionPoint`
  /// in `oldMasked`, producing `newMasked`.
  static func offsetAfterInsertion(
    oldMasked: String, newMasked: String, mask: String, at insertionPoint: Int
  ) -> Int {
    let maskChars = Array(mask)

    // Count data chars before insertionPoint in the old masked string
    var dataRankBefore = 0
    for i in 0..<min(insertionPoint, maskChars.count) {
      let m = maskChars[i]
      if m == "9" || m == "A" || m == "*" { dataRankBefore += 1 }
    }

    // Find position after the (dataRankBefore + 1)-th data char in new masked string
    let targetRank = dataRankBefore + 1
    var dataCount = 0
    for i in 0..<min(newMasked.count, maskChars.count) {
      let m = maskChars[i]
      if m == "9" || m == "A" || m == "*" {
        dataCount += 1
        if dataCount == targetRank { return i + 1 }
      }
    }

    return newMasked.count
  }

  static func apply(to textField: UITextField, masked: String, mask: String) {
    let off = offsetAtEnd(masked: masked, mask: mask)
    guard let pos = textField.position(from: textField.beginningOfDocument, offset: off) else {
      return
    }
    textField.selectedTextRange = textField.textRange(from: pos, to: pos)
  }
}
