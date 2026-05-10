import type { HybridObject } from 'react-native-nitro-modules'

export interface NitroInputMaskService extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  applyMask(value: string, mask: string): string
}
