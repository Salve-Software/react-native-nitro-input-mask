import type { HybridObject } from 'react-native-nitro-modules'

export interface NitroInputMask extends HybridObject<{ ios: 'swift'; android: 'kotlin' }> {
  attach(nativeID: string, mask: string): void
  detach(nativeID: string): void
  updateMask(nativeID: string, mask: string): void
  setValue(nativeID: string, rawValue: string): void
}
