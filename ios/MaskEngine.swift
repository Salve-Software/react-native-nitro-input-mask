import Foundation

// MARK: - Slot

private enum Slot {
  case digit
  case letter
  case any
  case literal(Character)
  case range(blockName: String, length: Int, from: Int, to: Int)
}

// MARK: - CompiledMask

struct CompiledMask {
  fileprivate let slots: [Slot]
  let expandedMask: String
  var isEmpty: Bool { slots.isEmpty }
}

// MARK: - MaskEngine

enum MaskEngine {

  // MARK: compile

  /// Compiles a mask string into a `CompiledMask`.
  ///
  /// Supported tokens:
  /// - `9`        — any digit
  /// - `A`        — any letter
  /// - `*`        — any alphanumeric
  /// - `[from-to]` — integer range, e.g. `[1-12]`, `[1-31]`, `[0-23]`
  /// - any other character — literal
  ///
  /// Note: two `[from-to]` blocks with identical bounds share the same
  /// `blockName` key and therefore share partial-tracking state during
  /// `apply`. This is an acceptable trade-off; prefer distinct bounds when
  /// designing date masks (e.g. `[1-12]/[1-31]/9999`).
  static func compile(mask: String) -> CompiledMask {
    var slots: [Slot] = []
    var expandedMask = ""
    var i = mask.startIndex

    while i < mask.endIndex {
      if mask[i] == "[" {
        guard let closeIdx = mask[i...].firstIndex(of: "]") else {
          // Malformed — treat "[" as a literal and advance past it.
          slots.append(.literal("["))
          expandedMask.append("[")
          i = mask.index(after: i)
          continue
        }
        
        let content = String(mask[mask.index(after: i)..<closeIdx]) // e.g. "1-12"
        let parts = content.split(separator: "-", maxSplits: 1)
        if parts.count == 2, let from = Int(parts[0]), let to = Int(parts[1]) {
          let length = max(String(from).count, String(to).count)
          for _ in 0..<length {
            slots.append(.range(blockName: content, length: length, from: from, to: to))
            expandedMask.append("9")
          }
        } 
        else {
          // Malformed range — emit the entire "[...]" as individual literals.
          let literal = "[" + content + "]"
          for c in literal {
            slots.append(.literal(c))
            expandedMask.append(c)
          }
        }
        i = mask.index(after: closeIdx)
      } 
      else {
        switch mask[i] {
        case "9":
          slots.append(.digit)
          expandedMask.append("9")
          
        case "A":
          slots.append(.letter)
          expandedMask.append("A")
          
        case "*":
          slots.append(.any)
          expandedMask.append("*")
          
        default:
          slots.append(.literal(mask[i]))
          expandedMask.append(mask[i])
        }
        i = mask.index(after: i)
      }
    }

    return CompiledMask(slots: slots, expandedMask: expandedMask)
  }

  // MARK: apply

  static func apply(input: String, compiled: CompiledMask) -> (masked: String, raw: String) {
    if compiled.slots.isEmpty { return (input, input) }

    var masked = ""
    var raw = ""
    let slots = compiled.slots
    let inputChars = Array(input)
    var ii = 0
    var si = 0
    var blockPartials: [String: String] = [:]

    while si < slots.count && ii < inputChars.count {
      let slot = slots[si]
      let c = inputChars[ii]

      switch slot {
      case .digit:
        if c.isNumber {
          masked.append(c); raw.append(c); ii += 1; si += 1
        } 
        else {
          ii += 1
        }

      case .letter:
        if c.isLetter {
          masked.append(c); raw.append(c); ii += 1; si += 1
        } 
        else {
          ii += 1
        }

      case .any:
        if c.isLetter || c.isNumber {
          masked.append(c); raw.append(c); ii += 1; si += 1
        } 
        else {
          ii += 1
        }

      case .literal(let lc):
        masked.append(lc)
        if c == lc { ii += 1 }
        si += 1

      case .range(let blockName, let length, let from, let to):
        if c.isNumber {
          let partial = blockPartials[blockName, default: ""]
          let newPartial = partial + String(c)
          if isValidPrefix(partial: newPartial, from: from, to: to, length: length) {
            masked.append(c); raw.append(c)
            blockPartials[blockName] = newPartial
            ii += 1; si += 1
          } 
          else {
            ii += 1
          }
        } 
        else {
          ii += 1
        }
      }
    }

    // Only emit trailing literals if some input was actually consumed.
    if ii > 0 {
      while si < slots.count, case .literal(let lc) = slots[si] {
        masked.append(lc)
        si += 1
      }
    }

    return (masked, raw)
  }

  // MARK: extractRaw

  static func extractRaw(from text: String, compiled: CompiledMask) -> String {
    return extractRaw(from: text, mask: compiled.expandedMask)
  }

  // MARK: Private helpers

  private static func extractRaw(from text: String, mask: String) -> String {
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
      } 
      else {
        if textChars[ti] == maskChars[mi] { ti += 1 }
        mi += 1
      }
    }

    return raw
  }

  private static func isValidPrefix(partial: String, from: Int, to: Int, length: Int) -> Bool {
    let remaining = length - partial.count
    guard remaining >= 0 else { return false }
    guard
      let partialMin = Int(partial + String(repeating: "0", count: remaining)),
      let partialMax = Int(partial + String(repeating: "9", count: remaining))
    else { return false }
    
    return partialMin <= to && partialMax >= from
  }
}
