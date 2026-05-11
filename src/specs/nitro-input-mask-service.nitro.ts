import type { HybridObject } from 'react-native-nitro-modules'
import type { NitroMaskOptions } from './nitro-input-mask.nitro'

// Declared inline to ensure Nitro codegen can resolve the type without
// cross-file imports, which some versions of nitrogen reject.
// Keep in sync with src/types/MaskResult.ts.
export interface MaskResult {
  masked: string
  raw: string
}

export interface NitroInputMaskService extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  applyMask(value: string, maskType: string, options: NitroMaskOptions): MaskResult
}
