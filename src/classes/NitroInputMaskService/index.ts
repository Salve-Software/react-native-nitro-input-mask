import { getNitroServiceModule } from '../../nitro-module'
import type { IApplyMaskProps } from './types'

export type { IApplyMaskProps } from './types'

export class NitroInputMaskService {
  static applyMask = (props: IApplyMaskProps): string => {
    const value = String(props.value ?? '')
    const mask = String(props.mask ?? '')

    if (!mask) return ''

    if (value.length > 1000 || mask.length > 200) {
      throw new Error('NitroInputMaskService: value or mask exceeds maximum allowed length')
    }

    return getNitroServiceModule().applyMask(value, mask)
  }
}