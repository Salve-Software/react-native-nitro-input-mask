import type {
  HybridView,
  HybridViewProps,
  HybridViewMethods,
} from 'react-native-nitro-modules'

export interface NitroMaskProps extends HybridViewProps {
   mask: string
   value: string
   onChangeText?: (maskedValue: string, rawValue: string) => void
}

export interface NitroMaskMethods extends HybridViewMethods {}

export type NitroMask = HybridView<NitroMaskProps, NitroMaskMethods, { ios: 'swift', android: 'kotlin' }>
