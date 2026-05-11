import type { IApplyMaskProps } from './types';
import type { MaskResult } from '../../types';
import { getNitroServiceModule } from '../../nitro-module';

/**
 * Standalone service for applying input masks natively.
 *
 * Runs the same mask engine used by `<NitroInputMask />`, but as a
 * plain function call — no component or ref required.
 *
 * @example
 * const { masked, raw } = NitroInputMaskService.applyMask({
 *   value: '12345678901',
 *   maskOptions: { mask: '999.999.999-99' },
 * })
 * // masked: '123.456.789-01'
 * // raw:    '12345678901'
 *
 * @example
 * const { masked, raw } = NitroInputMaskService.applyMask({
 *   value: '123456',
 *   maskType: 'money',
 *   maskOptions: { unit: 'R$ ', precision: 2 },
 * })
 * // masked: 'R$ 1.234,56'
 * // raw:    '123456'  (digit-only string for money masks)
 */
export class NitroInputMaskService {
  /**
   * Applies a mask to a string and returns both the masked and raw values.
   *
   * For `custom` masks, tokens are:
   * - `9` — digit (0–9)
   * - `A` — letter (a–z, A–Z)
   * - `*` — letter or digit
   * - `[n-m]` — integer in the inclusive range n–m (e.g. `[1-12]`, `[1-31]`)
   * - Any other character — treated as a literal and inserted as-is
   *
   * @param props.value       - The raw string to mask.
   * @param props.maskType    - The mask type: `'custom'` (default), `'money'`, `'datetime'`, `'credit-card'`.
   * @param props.maskOptions - Options specific to the chosen mask type.
   * @returns `{ masked, raw }` — the formatted string and the unformatted input.
   *          For money masks, `raw` is a digit-only string.
   *
   * @throws If `value` exceeds 1000 characters or `custom` mask exceeds 200 characters.
   *
   * @example
   * const { masked } = NitroInputMaskService.applyMask({
   *   value: '11987654321',
   *   maskOptions: { mask: '(99) 99999-9999' },
   * })
   * // masked: '(11) 98765-4321'
   */
  static applyMask = (props: IApplyMaskProps): MaskResult => {
    const { value, maskType, maskOptions } = props as IApplyMaskProps & {
      maskType?: string;
      maskOptions?: Record<string, unknown>;
    };

    const resolvedValue = String(value ?? '');
    const resolvedMaskType = maskType ?? 'custom';
    const resolvedOptions = maskOptions ?? {};

    if (resolvedMaskType === 'custom') {
      const mask = String((resolvedOptions as { mask?: string }).mask ?? '');
      if (!mask) return { masked: resolvedValue, raw: resolvedValue };
      if (resolvedValue.length > 1000 || mask.length > 200) {
        throw new Error('NitroInputMaskService: value or mask exceeds maximum allowed length');
      }
    }

    return getNitroServiceModule().applyMask(resolvedValue, resolvedMaskType, resolvedOptions);
  }
}
