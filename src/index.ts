import { getHostComponent, type HybridRef } from 'react-native-nitro-modules'
import NitroMaskConfig from '../nitrogen/generated/shared/json/NitroMaskConfig.json'
import type {
  NitroMaskProps as NitroMaskSpecProps,
  NitroMaskMethods,
} from './specs/nitro-mask.nitro'
import type { ViewStyle } from 'react-native'

export type NitroMaskProps = {
  mask: string
  value: string
  onChangeText: (maskedValue: string, rawValue: string) => void
  style?: ViewStyle
  testID?: string
}

export const NitroMask = getHostComponent<NitroMaskSpecProps, NitroMaskMethods>(
  'NitroMask',
  () => NitroMaskConfig
)

export type NitroMaskRef = HybridRef<NitroMaskSpecProps, NitroMaskMethods>
