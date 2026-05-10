import type { HybridObject } from 'react-native-nitro-modules'

export interface NitroInputMaskServiceSpec extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  applyMask(value: string, mask: string): string
}
