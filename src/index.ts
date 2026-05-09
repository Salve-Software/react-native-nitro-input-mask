import type {
  NitroMaskProps as NitroMaskSpecProps,
  NitroMaskMethods,
} from './specs/nitro-mask.nitro';
import type { HybridRef } from 'react-native-nitro-modules';
import type { ViewStyle } from 'react-native';
import { getHostComponent } from 'react-native-nitro-modules';
import NitroMaskConfig from '../nitrogen/generated/shared/json/NitroMaskConfig.json';

export type NitroMaskProps = NitroMaskSpecProps & {
  style?: ViewStyle;
  testID?: string;
};

export const NitroMask = getHostComponent<NitroMaskSpecProps, NitroMaskMethods>(
  'NitroMask',
  () => NitroMaskConfig,
);

export type NitroMaskRef = HybridRef<NitroMaskSpecProps, NitroMaskMethods>;
