import { getHostComponent, type HybridRef } from 'react-native-nitro-modules'
import NitroMaskConfig from '../nitrogen/generated/shared/json/NitroMaskConfig.json'
import type {
  NitroMaskProps,
  NitroMaskMethods,
} from './specs/nitro-mask.nitro'


export const NitroMask = getHostComponent<NitroMaskProps, NitroMaskMethods>(
  'NitroMask',
  () => NitroMaskConfig
)

export type NitroMaskRef = HybridRef<NitroMaskProps, NitroMaskMethods>
