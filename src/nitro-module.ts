import type { NitroInputMask as NitroInputMaskModule } from './specs/nitro-input-mask.nitro';
import type { NitroInputMaskServiceSpec } from './specs/nitro-input-mask-service.nitro';
import { NitroModules } from 'react-native-nitro-modules';

export const nitroModule = NitroModules.createHybridObject<NitroInputMaskModule>('NitroInputMask');

let _nitroServiceModule: NitroInputMaskServiceSpec | null = null
export const getNitroServiceModule = () => {
  if (!_nitroServiceModule) {
    _nitroServiceModule = NitroModules.createHybridObject<NitroInputMaskServiceSpec>('NitroInputMaskService')
  }
  return _nitroServiceModule
}
