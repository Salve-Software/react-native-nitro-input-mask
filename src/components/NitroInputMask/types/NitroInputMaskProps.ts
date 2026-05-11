import type { TextInputProps } from 'react-native';
import type { MaskConfig, MaskResult } from '../../../types';

export type NitroInputMaskProps = TextInputProps & MaskConfig & {
  /**
   * Called on every edit with both the masked display value and the raw
   * unformatted value, giving consumers a single callback for both.
   *
   * For money masks, `raw` is a digit-only string.
   *
   * @example
   * <NitroInputMask
   *   maskOptions={{ mask: '(999) 999-9999' }}
   *   onChangeValue={({ masked, raw }) => {
   *     setDisplay(masked)
   *     setDigits(raw)
   *   }}
   * />
   */
  onChangeValue?: (result: MaskResult) => void
}
