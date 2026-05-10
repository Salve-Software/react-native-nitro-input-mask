import type { NitroInputMask as NitroInputMaskModule } from './specs/nitro-input-mask.nitro';
import type { NitroInputMaskService } from './specs/nitro-input-mask-service.nitro';
import { NitroModules } from 'react-native-nitro-modules';

export const nitroModule = NitroModules.createHybridObject<NitroInputMaskModule>('NitroInputMask');
export const nitroServiceModule = NitroModules.createHybridObject<NitroInputMaskService>('NitroInputMaskService');
