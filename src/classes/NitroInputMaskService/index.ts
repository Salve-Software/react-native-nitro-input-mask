import type { IApplyMaskProps } from './types';
import { getNitroServiceModule } from '../../nitro-module';

/**
 * Standalone service for applying input masks natively.
 *
 * Runs the same mask engine used by `<NitroInputMask />`, but as a
 * plain function call — no component or ref required.
 *
 * @example
 * const masked = NitroInputMaskService.applyMask({
 *   value: '12345678901',
 *   mask: '999.999.999-99',
 * })
 * // '123.456.789-01'
 */
export class NitroInputMaskService {
  /**
   * Applies a mask pattern to a string and returns the masked result.
   *
   * Mask tokens:
   * - `9` — digit (0–9)
   * - `A` — letter (a–z, A–Z)
   * - `*` — letter or digit
   * - Any other character — treated as a literal and inserted as-is
   *
   * @param props.value - The raw string to mask.
   * @param props.mask  - The mask pattern to apply.
   * @returns The masked string.
   *
   * @throws If `value` exceeds 1000 characters or `mask` exceeds 200 characters.
   *
   * @example
   * NitroInputMaskService.applyMask({ value: '11987654321', mask: '(99) 99999-9999' })
   * // '(11) 98765-4321'
   */
  static applyMask = (props: IApplyMaskProps): string => {
    const value = String(props.value ?? '');
    const mask = String(props.mask ?? '');

    if (!mask) return value;

    if (value.length > 1000 || mask.length > 200) {
      throw new Error('NitroInputMaskService: value or mask exceeds maximum allowed length');
    }

    return getNitroServiceModule().applyMask(value, mask);
  }
}

export type { IApplyMaskProps } from './types';
