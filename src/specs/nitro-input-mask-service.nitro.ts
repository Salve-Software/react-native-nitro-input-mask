import type { HybridObject } from 'react-native-nitro-modules'
import type { NitroMaskOptions } from './nitro-input-mask.nitro'

export interface NitroInputMaskService extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  applyMask(value: string, maskType: string, options: NitroMaskOptions): string
}
