import type {
  HybridView,
  HybridViewProps,
  HybridViewMethods,
} from 'react-native-nitro-modules'

export interface NitroMaskProps extends HybridViewProps {
   isRed: boolean
}

export interface NitroMaskMethods extends HybridViewMethods {}

export type NitroMask = HybridView<NitroMaskProps, NitroMaskMethods, { ios: 'swift', android: 'kotlin' }>