## [Unreleased]

### ⚠️ Breaking Changes

- `NitroInputMaskService.applyMask()` now returns `{ masked: string; raw: string }` instead of a plain `string`.
  Migrate by destructuring: `const { masked } = NitroInputMaskService.applyMask(props)`

### ✨ New Features

- **`MaskResult` type** — canonical `{ masked, raw }` return type exported from the package root
- **`onChangeValue` prop on `<NitroInputMask />`** — fires `(result: MaskResult) => void` on every edit,
  giving consumers both the formatted display value and the raw unformatted input in a single callback.
  For money masks, `raw` is a digit-only string.

---

## 1.0.0 (2026-05-11)

### ✨Initial release

High-performance native input masks for React Native, built on [Nitro Modules](https://github.com/mrousavy/nitro).

- **`<NitroInputMask />`** — drop-in replacement for `<TextInput />` with synchronous native masking (zero JS flicker)
- **`NitroInputMaskService`** — apply any mask to a string without rendering a component
- **Built-in mask types** — `custom`, `money`, `datetime`, `credit-card`
- **Range tokens** — inline `[from-to]` syntax (e.g. `[1-12]` for month)
- iOS (Swift) and Android (Kotlin) support