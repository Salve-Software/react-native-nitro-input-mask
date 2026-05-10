protocol MaskEngineProtocol {
  func apply(input: String) -> (masked: String, raw: String)
  var wantsTrailingCursor: Bool { get }
  /// Expanded mask string used for cursor positioning (e.g. "999.999.999-99").
  /// Return nil if cursor should just go to end of masked string.
  var expandedMask: String? { get }
}
