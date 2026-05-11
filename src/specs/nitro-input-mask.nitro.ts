import type { HybridObject } from 'react-native-nitro-modules'

export interface NitroMaskOptions {
  // custom
  mask?: string
  // money
  precision?: number
  separator?: string
  delimiter?: string
  unit?: string
  suffixUnit?: string
  zeroCents?: boolean
  // datetime
  format?: string
  // credit-card
  issuer?: string
  obfuscated?: boolean
}

export interface NitroInputMask extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  attach(nativeID: string, maskType: string, options: NitroMaskOptions): void
  detach(nativeID: string): void
  updateMask(nativeID: string, maskType: string, options: NitroMaskOptions): void
  setValue(nativeID: string, rawValue: string): void
}
