//
//  HybridNitroMask.swift
//  Pods
//
//  Created by salvesoftware on 5/8/2026.
//

import Foundation
import UIKit

class HybridNitroMask : HybridNitroMaskSpec {
  // UIView
  var view: UIView = UIView()

  // Props
  var isRed: Bool = false {
    didSet {
      view.backgroundColor = isRed ? .red : .black
    }
  }
}
