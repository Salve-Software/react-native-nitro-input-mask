import UIKit
import NitroModules

private let attachRetries = 5
private let attachRetryDelay: TimeInterval = 0.05

class HybridNitroInputMaskModule: HybridNitroInputMaskSpec_base, HybridNitroInputMaskSpec_protocol {
  private var proxies: [String: NitroInputMaskDelegateProxy] = [:]

  func attach(nativeID: String, mask: String) throws {
    attemptAttach(nativeID: nativeID, mask: mask, retries: attachRetries)
  }

  private func attemptAttach(nativeID: String, mask: String, retries: Int) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      if let tf = self.findTextField(nativeID: nativeID) {
        let proxy = NitroInputMaskDelegateProxy(mask: mask, original: tf.delegate)
        tf.delegate = proxy
        self.proxies[nativeID] = proxy
      } else if retries > 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + attachRetryDelay) { [weak self] in
          self?.attemptAttach(nativeID: nativeID, mask: mask, retries: retries - 1)
        }
      }
    }
  }

  func detach(nativeID: String) throws {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard let proxy = self.proxies.removeValue(forKey: nativeID) else { return }
      if let tf = self.findTextField(nativeID: nativeID) {
        tf.delegate = proxy.original
      }
    }
  }

  func updateMask(nativeID: String, mask: String) throws {
    proxies[nativeID]?.mask = mask
  }

  func setValue(nativeID: String, rawValue: String) throws {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard let proxy = self.proxies[nativeID] else { return }
      guard let tf = self.findTextField(nativeID: nativeID) else { return }
      let (masked, _) = MaskEngine.apply(input: rawValue, mask: proxy.mask)
      tf.text = masked
      CursorEngine.apply(to: tf, masked: masked, mask: proxy.mask)
    }
  }

  private func findTextField(nativeID: String) -> UITextField? {
    let windows: [UIWindow]
    if #available(iOS 15.0, *) {
      windows = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
    } else {
      windows = UIApplication.shared.windows
    }
    for window in windows {
      if let container = findView(in: window, identifier: nativeID),
         let tf = findFirstTextField(in: container) {
        return tf
      }
    }
    return nil
  }

  private func findView(in view: UIView, identifier: String) -> UIView? {
    // Fabric (New Arch) stores nativeID as `nativeId` (lowercase d) on RCTViewComponentView.
    // Old arch stores it as `nativeID` (uppercase D) via the UIView+React category.
    for selName in ["nativeId", "nativeID"] {
      let sel = NSSelectorFromString(selName)
      if view.responds(to: sel),
         let id = view.perform(sel)?.takeUnretainedValue() as? String,
         id == identifier {
        return view
      }
    }
    for sv in view.subviews {
      if let found = findView(in: sv, identifier: identifier) { return found }
    }
    return nil
  }

  private func findFirstTextField(in view: UIView) -> UITextField? {
    if let tf = view as? UITextField { return tf }
    for sv in view.subviews {
      if let found = findFirstTextField(in: sv) { return found }
    }
    return nil
  }
}
