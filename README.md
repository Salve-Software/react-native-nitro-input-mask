# react-native-nitro-input-mask

Native input masks for React Native — zero JS flicker, built on [Nitro Modules](https://github.com/mrousavy/nitro).

[![npm version](https://img.shields.io/npm/v/@salve-software/react-native-nitro-input-mask.svg)](https://www.npmjs.com/package/@salve-software/react-native-nitro-input-mask)
[![npm downloads](https://img.shields.io/npm/dm/@salve-software/react-native-nitro-input-mask.svg)](https://www.npmjs.com/package/@salve-software/react-native-nitro-input-mask)
[![License](https://img.shields.io/npm/l/@salve-software/react-native-nitro-input-mask.svg)](./LICENSE)

<p align="center">
  <img src="./assets/demo.gif" width="320" />
</p>

---

## Why

Most React Native mask libraries apply the mask in JavaScript — every keystroke crosses the bridge before the field is updated, causing a visible flicker.

`react-native-nitro-input-mask` runs the entire mask engine natively (Swift on iOS, Kotlin on Android) via Nitro Modules, so the field is updated synchronously with no flicker.

## Features

- **Zero flicker** — mask applied synchronously on the native side
- **`<NitroInputMask />`** — drop-in replacement for React Native's `<TextInput />`
- **`NitroInputMaskService`** — apply a mask to any string without a component
- **Built-in mask types** — `custom`, `money`, `datetime`, `credit-card`
- **Range tokens** — e.g. `[1-12]` for month, `[1-31]` for day
- iOS and Android support

## Requirements

| | Minimum |
|---|---|
| React Native | 0.78 |
| Node | 18 |

> **New Architecture only.** The Old Architecture is not supported.

## Installation

```sh
npm install react-native-nitro-input-mask react-native-nitro-modules
```

```sh
yarn add react-native-nitro-input-mask react-native-nitro-modules
```

```sh
bun add react-native-nitro-input-mask react-native-nitro-modules
```

### iOS

```sh
cd ios && pod install
```

## Usage

### `<NitroInputMask />`

Drop-in replacement for `<TextInput />`. Accepts all standard `TextInputProps` plus `maskType` and `maskOptions`.

```tsx
import React, { useState } from 'react'
import { NitroInputMask } from 'react-native-nitro-input-mask'

function PhoneInput() {
  const [value, setValue] = useState('')

  return (
    <NitroInputMask
      maskOptions={{ mask: '(999) 999-9999' }}
      placeholder="(555) 000-0000"
      keyboardType="numeric"
      onChangeText={setValue}
    />
  )
}
```

Use `onChangeValue` to receive both the masked display value and the raw unformatted digits in one callback:

```tsx
import React, { useState } from 'react'
import type { MaskResult } from 'react-native-nitro-input-mask'
import { NitroInputMask } from 'react-native-nitro-input-mask'

function PhoneInput() {
  const [display, setDisplay] = useState('')
  const [digits, setDigits] = useState('')

  function handleChangeValue({ masked, raw }: MaskResult) {
    setDisplay(masked) // '(555) 123-4567'
    setDigits(raw)     // '5551234567'
  }

  return (
    <NitroInputMask
      maskOptions={{ mask: '(999) 999-9999' }}
      placeholder="(555) 000-0000"
      keyboardType="numeric"
      value={display}
      onChangeValue={handleChangeValue}
    />
  )
}
```

```tsx
// Money
<NitroInputMask
  maskType="money"
  maskOptions={{ unit: '$ ', precision: 2 }}
  keyboardType="numeric"
  onChangeText={setValue}
/>

// Date
<NitroInputMask
  maskType="datetime"
  maskOptions={{ format: 'MM/DD/YYYY' }}
  keyboardType="numeric"
  onChangeText={setValue}
/>

// Credit card
<NitroInputMask
  maskType="credit-card"
  maskOptions={{ issuer: 'visa-or-mastercard' }}
  keyboardType="numeric"
  onChangeText={setValue}
/>
```

### `NitroInputMaskService`

Apply a mask to any string — useful for formatting values in lists, previews, etc.

```tsx
import { NitroInputMaskService } from 'react-native-nitro-input-mask'

const { masked, raw } = NitroInputMaskService.applyMask({
  value: '5551234567',
  maskOptions: { mask: '(999) 999-9999' },
})
// masked: '(555) 123-4567'
// raw:    '5551234567'

const { masked: maskedMoney } = NitroInputMaskService.applyMask({
  value: '123456',
  maskType: 'money',
  maskOptions: { unit: '$ ', precision: 2 },
})
// maskedMoney: '$ 1,234.56'

const { masked: maskedDate } = NitroInputMaskService.applyMask({
  value: '06252025',
  maskType: 'datetime',
  maskOptions: { format: 'MM/DD/YYYY' },
})
// maskedDate: '06/25/2025'
```

## Mask Syntax

| Token | Accepts |
|---|---|
| `9` | Digit (0–9) |
| `A` | Letter (a–z, A–Z) |
| `*` | Letter or digit |
| `[n-m]` | Integer in range n–m (e.g. `[1-12]`, `[1-31]`) |
| Any other character | Literal — inserted as-is |

## API

### `<NitroInputMask />`

Extends React Native's [`TextInputProps`](https://reactnative.dev/docs/textinput#props).

| Prop | Type | Description |
|---|---|---|
| `maskType` | `'custom' \| 'money' \| 'datetime' \| 'credit-card'` | Mask type (default `'custom'`) |
| `maskOptions` | See table below | Options for the chosen mask type |
| `onChangeValue` | `(result: MaskResult) => void` | Fires on every edit with `{ masked, raw }` |

| maskType | maskOptions | Docs |
|---|---|---|
| `'custom'` (default) | `{ mask: string }` | [docs/custom.md](./docs/custom.md) |
| `'money'` | `{ precision?, separator?, delimiter?, unit?, suffixUnit?, zeroCents? }` | [docs/money.md](./docs/money.md) |
| `'datetime'` | `{ format: string }` | [docs/datetime.md](./docs/datetime.md) |
| `'credit-card'` | `{ issuer?, obfuscated? }` | [docs/credit-card.md](./docs/credit-card.md) |

### `NitroInputMaskService.applyMask(props)`

| Prop | Type | Description |
|---|---|---|
| `value` | `string` | The raw string to mask |
| `maskType` | `'custom' \| 'money' \| 'datetime' \| 'credit-card'` | Mask type (default `'custom'`) |
| `maskOptions` | See table above | Options for the chosen mask type |

Returns `MaskResult`:

| Field | Type | Description |
|---|---|---|
| `masked` | `string` | Formatted string as displayed to the user |
| `raw` | `string` | Unformatted input. For money masks, this is digit-only. |

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create your branch: `git checkout -b feat/your-feature`
3. Commit your changes following [Conventional Commits](https://www.conventionalcommits.org/)
4. Open a pull request

## License

MIT © [Salve Software](https://github.com/Salve-Software)
