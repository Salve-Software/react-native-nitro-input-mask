import { nitroServiceModule } from '../../nitro-module'
import type { IApplyMaskProps } from './types'

export class NitroInputMaskService {
  static applyMask = (props: IApplyMaskProps): string => {
    const { value, mask } = props
    return nitroServiceModule.applyMask(value, mask)
  }
}