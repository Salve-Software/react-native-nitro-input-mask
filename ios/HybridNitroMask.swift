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
      guard value != textField.text else { return }
      let (masked, _) = HybridNitroMask.applyMask(input: value, mask: mask)
      textField.text = masked
    }
  }

  var onChangeText: (_ maskedValue: String, _ rawValue: String) -> Void = { _, _ in }

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
      onChangeText(proposed, proposed)
      return false
    }

    let (masked, raw) = HybridNitroMask.applyMask(input: proposed, mask: mask)
    textField.text = masked

    // Move caret to end
    let end = textField.endOfDocument
    textField.selectedTextRange = textField.textRange(from: end, to: end)

    onChangeText(masked, raw)
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
        // literal — skip it in text
        ti += 1
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
