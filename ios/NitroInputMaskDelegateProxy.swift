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
    // cursor moves to just before the separator). If there is no data, clear the field.
    var isSeparatorDeletion = false
    if isDeletion && masked == current {
      let (_, extractedRaw) = engine.apply(input: current)
      if extractedRaw.isEmpty {
        masked = ""
      } else {
        isSeparatorDeletion = true
        // masked stays == current; cursor will move to range.location below
      }
    }

    textField.text = masked

    if engine.wantsTrailingCursor {
      let cursorPos: Int
      if isSeparatorDeletion {
        // Separator deleted: move to just before it so next backspace hits a real digit.
        cursorPos = range.location
      } else if isDeletion {
        // Count digits before the deleted range in the old text, then land after
        // the same number of digits in the new text. This survives separator
        // additions/removals (e.g. thousands dot disappearing after a deletion).
        let digitsBeforeRange = countDigitsUpTo(in: current, upTo: range.location)
        cursorPos = positionAfterDigits(digitsBeforeRange, in: masked)
      } else {
        // Insertion: use "digits from end" so cursor survives magnitude changes.
        let digitsAfterCursor = countDigits(in: current, from: range.location + range.length)
        cursorPos = cursorPositionWithDigitsAfter(digitsAfterCursor, in: masked)
      }
      if let pos = textField.position(from: textField.beginningOfDocument, offset: cursorPos) {
        textField.selectedTextRange = textField.textRange(from: pos, to: pos)
      }
    } else if let expandedMask = engine.expandedMask {
      let cursorOffset: Int
      if isDeletion {
        cursorOffset = min(range.location, masked.count)
      } else {
        let raw = CursorEngine.offsetAfterInsertion(
          oldMasked: current,
          newMasked: masked,
          mask: expandedMask,
          at: range.location
        )
        // Advance past any auto-inserted literals immediately following the cursor.
        cursorOffset = skipLeadingLiterals(at: raw, in: masked, mask: expandedMask)
      }
      if let pos = textField.position(from: textField.beginningOfDocument, offset: cursorOffset) {
        textField.selectedTextRange = textField.textRange(from: pos, to: pos)
      }
    } else {
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

  // MARK: - Cursor helpers

  /// Advances `offset` past any consecutive literal slots in `mask`, so the
  /// cursor lands after auto-inserted separators rather than before them.
  private func skipLeadingLiterals(at offset: Int, in masked: String, mask: String) -> Int {
    let dataTokens: Set<Character> = ["9", "A", "*"]
    let maskChars = Array(mask)
    var idx = offset
    while idx < maskChars.count && !dataTokens.contains(maskChars[idx]) {
      idx += 1
    }
    return min(idx, masked.count)
  }

  /// Counts digit characters in `text` before index `upTo`.
  private func countDigitsUpTo(in text: String, upTo: Int) -> Int {
    let chars = Array(text)
    let limit = min(upTo, chars.count)
    return chars[0..<limit].filter { $0.isNumber }.count
  }

  /// Returns the position in `text` immediately after the `count`-th digit.
  /// Falls back to `text.count` when fewer digits exist.
  private func positionAfterDigits(_ count: Int, in text: String) -> Int {
    if count == 0 { return 0 }
    let chars = Array(text)
    var found = 0
    for (i, c) in chars.enumerated() {
      if c.isNumber {
        found += 1
        if found == count { return i + 1 }
      }
    }
    return text.count
  }

  /// Returns how many digit characters exist in `text` starting from `start`.
  private func countDigits(in text: String, from start: Int) -> Int {
    guard start < text.count else { return 0 }
    let chars = Array(text)
    var count = 0
    for i in start..<chars.count where chars[i].isNumber {
      count += 1
    }
    return count
  }

  /// Returns the cursor position in `text` such that exactly `count` digit
  /// characters appear after it. Used for RTL money masks so the cursor
  /// stays near the edit point after reformatting.
  private func cursorPositionWithDigitsAfter(_ count: Int, in text: String) -> Int {
    if count == 0 { return text.count }
    let chars = Array(text)
    var digitsFromEnd = 0
    var pos = chars.count
    while pos > 0 {
      pos -= 1
      if chars[pos].isNumber {
        digitsFromEnd += 1
        if digitsFromEnd == count { return pos }
      }
    }
    return 0
  }
}
