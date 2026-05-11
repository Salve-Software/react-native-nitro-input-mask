/**
 * The result returned by `NitroInputMaskService.applyMask()` and
 * delivered to `<NitroInputMask onChangeValue />`.
 *
 * - `masked` — the formatted string as displayed to the user (e.g. `"(555) 123-4567"`)
 * - `raw`    — the unformatted input stripped of mask literals.
 *              For money masks this is a digit-only string (e.g. `"123456"`).
 */
export type MaskResult = {
  masked: string
  raw: string
}
