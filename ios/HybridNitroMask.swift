//
//  HybridNitroMask.swift
//  Pods
//
//  Created by salvesoftware on 5/8/2026.
//

import Foundation
import UIKit
import NitroModules

class HybridNitroMask: HybridNitroMaskSpec, UITextFieldDelegate {
  // UITextField as the view
  private let textField = UITextField()

  var view: UIView { textField }

  // Props
  var mask: String = "" {
    didSet {
      let raw = extractRaw(from: textField.text ?? "", mask: oldValue)
      let (masked, _) = HybridNitroMask.applyMask(input: raw, mask: mask)
      textField.text = masked
    }
  }

  var value: String = "" {
    didSet {
      let currentRaw = extractRaw(from: textField.text ?? "", mask: mask)
      guard value != currentRaw else { return }
      let (masked, _) = HybridNitroMask.applyMask(input: value, mask: mask)
      textField.text = masked
    }
  }

  var onChangeText: ((_ maskedValue: String, _ rawValue: String) -> Void)? = nil

  override init() {
    super.init()
    textField.delegate = self
    textField.borderStyle = .none
  }

  // MARK: - UITextFieldDelegate

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
      onChangeText?(proposed, proposed)
      return false
    }

    let isDeletion = string.isEmpty
    var (masked, raw) = HybridNitroMask.applyMask(input: proposed, mask: mask)

    // Issue 10: if deleting landed back on the same text, a literal was deleted — strip one more raw char
    if isDeletion && masked == current {
      let currentRaw = extractRaw(from: current, mask: mask)
      if !currentRaw.isEmpty {
        let trimmedRaw = String(currentRaw.dropLast())
        (masked, _) = HybridNitroMask.applyMask(input: trimmedRaw, mask: mask)
      }
    }

    textField.text = masked

    // Issue 4/5: place cursor after last user-typed character, not always at end
    let maskChars = Array(mask)
    var cursorOffset = masked.count
    let maskedChars = Array(masked)
    for i in stride(from: maskedChars.count - 1, through: 0, by: -1) {
      if i < maskChars.count {
        let m = maskChars[i]
        if m == "9" || m == "A" || m == "*" {
          cursorOffset = i + 1
          break
        }
      }
    }
    if let targetPos = textField.position(from: textField.beginningOfDocument, offset: cursorOffset) {
      textField.selectedTextRange = textField.textRange(from: targetPos, to: targetPos)
    }

    onChangeText?(masked, raw)
    return false
  }

  // MARK: - Mask algorithm

  private func extractRaw(from text: String, mask: String) -> String {
    var raw = ""
    let textChars = Array(text)
    let maskChars = Array(mask)
    var ti = 0
    var mi = 0
    while ti < textChars.count && mi < maskChars.count {
      let m = maskChars[mi]
      let t = textChars[ti]
      if m == "9" || m == "A" || m == "*" {
        raw.append(t)
        ti += 1
        mi += 1
      } else {
        // literal — only consume text char if it matches the literal
        if ti < textChars.count && textChars[ti] == maskChars[mi] {
          ti += 1
        }
        mi += 1
      }
    }
    return raw
  }

  private static func applyMask(input: String, mask: String) -> (masked: String, raw: String) {
    var masked = ""
    var raw = ""
    let inputChars = Array(input)
    let maskChars = Array(mask)
    var ii = 0
    var mi = 0

    while mi < maskChars.count && ii < inputChars.count {
      let m = maskChars[mi]
      let c = inputChars[ii]

      switch m {
      case "9":
        if c.isNumber {
          masked.append(c)
          raw.append(c)
          ii += 1
        } else {
          ii += 1 // skip non-digit
          continue
        }
      case "A":
        if c.isLetter {
          masked.append(c)
          raw.append(c)
          ii += 1
        } else {
          ii += 1
          continue
        }
      case "*":
        if c.isLetter || c.isNumber {
          masked.append(c)
          raw.append(c)
          ii += 1
        } else {
          ii += 1
          continue
        }
      default:
        // Literal character — auto-insert
        masked.append(m)
        // If current input char equals the literal, consume it to avoid duplication on paste
        if c == m {
          ii += 1
        }
      }
      mi += 1
    }

    // Append any remaining literals from mask (if input still has chars)
    // Only do this if we haven't exhausted input
    // (No trailing literals — stop at end of input)

    return (masked, raw)
  }
}
