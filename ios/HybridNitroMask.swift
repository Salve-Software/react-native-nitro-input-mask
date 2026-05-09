//
//  HybridNitroMask.swift
//  Pods
//
//  Created by salvesoftware on 5/8/2026.
//

import Foundation
import UIKit
import NitroModules

// Separate NSObject delegate required because HybridNitroMaskSpec_base does not inherit NSObject
private class TextFieldDelegate: NSObject, UITextFieldDelegate {
  weak var owner: HybridNitroMask?

  func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    owner?.handleTextChange(textField, range: range, replacement: string) ?? true
  }
}

class HybridNitroMask: HybridNitroMaskSpec {
  private let textField = UITextField()
  private let tfDelegate = TextFieldDelegate()

  var view: UIView { textField }

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
    var (masked, raw) = HybridNitroMask.applyMask(input: proposed, mask: mask)

    if isDeletion && masked == current {
      let currentRaw = extractRaw(from: current, mask: mask)
      if !currentRaw.isEmpty {
        let trimmedRaw = String(currentRaw.dropLast())
        (masked, raw) = HybridNitroMask.applyMask(input: trimmedRaw, mask: mask)
      }
    }

    textField.text = masked

    let maskChars = Array(mask)
    let maskedChars = Array(masked)
    var cursorOffset = masked.count
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

  private func extractRaw(from text: String, mask: String) -> String {
    var raw = ""
    let textChars = Array(text)
    let maskChars = Array(mask)
    var ti = 0
    var mi = 0
    while ti < textChars.count && mi < maskChars.count {
      let m = maskChars[mi]
      if m == "9" || m == "A" || m == "*" {
        raw.append(textChars[ti])
        ti += 1
        mi += 1
      } else {
        if textChars[ti] == maskChars[mi] {
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
          masked.append(c); raw.append(c); ii += 1
        } else {
          ii += 1; continue
        }
      case "A":
        if c.isLetter {
          masked.append(c); raw.append(c); ii += 1
        } else {
          ii += 1; continue
        }
      case "*":
        if c.isLetter || c.isNumber {
          masked.append(c); raw.append(c); ii += 1
        } else {
          ii += 1; continue
        }
      default:
        masked.append(m)
        if c == m { ii += 1 }
      }
      mi += 1
    }

    return (masked, raw)
  }
}
