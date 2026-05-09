import Foundation

enum MaskEngine {
  static func apply(input: String, mask: String) -> (masked: String, raw: String) {
    if mask.isEmpty { return (input, input) }

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

  static func extractRaw(from text: String, mask: String) -> String {
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
}
