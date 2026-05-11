package com.nitroinputmask.engine

interface MaskEngineProtocol {
  fun apply(input: String): Pair<String, String>
  val wantsTrailingCursor: Boolean
  /** Expanded mask string for cursor positioning. Null means put cursor at end. */
  val expandedMask: String?
}
