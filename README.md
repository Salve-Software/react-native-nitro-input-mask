# react-native-nitro-input-mask

Native input masks for React Native — zero JS flicker, built on [Nitro Modules](https://github.com/mrousavy/nitro).

[![npm version](https://img.shields.io/npm/v/react-native-nitro-input-mask.svg)](https://www.npmjs.com/package/react-native-nitro-input-mask)
[![npm downloads](https://img.shields.io/npm/dm/react-native-nitro-input-mask.svg)](https://www.npmjs.com/package/react-native-nitro-input-mask)
[![License](https://img.shields.io/npm/l/react-native-nitro-input-mask.svg)](./LICENSE)

## Why

Most React Native mask libraries process input in JavaScript — the text has to cross the bridge before the mask is applied, causing a visible flicker on every keystroke.

`react-native-nitro-input-mask` runs the entire mask engine natively (Swift on iOS, Kotlin on Android) through Nitro Modules. The TextInput never leaves the native thread.

## Features

- **Zero flicker** — mask applied synchronously on the native side
- **`<NitroInputMask />`** — drop-in replacement for React Native's `<TextInput />`
- **`NitroInputMaskService`** — apply a mask to any string without a component
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

Drop-in replacement for `<TextInput />`. Accepts all standard `TextInputProps` plus a `mask` prop.

```tsx
import { NitroInputMask } from 'react-native-nitro-input-mask'

function CPFInput() {
  const [value, setValue] = useState('')

  return (
    <NitroInputMask
      mask="999.999.999-99"
      placeholder="000.000.000-00"
      keyboardType="numeric"
      onChangeText={setValue}
    />
  )
}
```

### `NitroInputMaskService`

Apply a mask to any string — useful for formatting values outside of a text input (lists, previews, etc.).

```tsx
import { NitroInputMaskService } from 'react-native-nitro-input-mask'

const cpf = NitroInputMaskService.applyMask({
  value: '12345678901',
  mask: '999.999.999-99',
})
// '123.456.789-01'

const phone = NitroInputMaskService.applyMask({
  value: '11987654321',
  mask: '(99) 99999-9999',
})
// '(11) 98765-4321'
```

## Mask Syntax

| Token | Accepts |
|---|---|
| `9` | Digit (0–9) |
| `A` | Letter (a–z, A–Z) |
| `*` | Letter or digit |
| `[n-m]` | Integer in range n–m (e.g. `[1-12]`, `[1-31]`) |
| Any other character | Literal — inserted as-is |

See [docs/mask-syntax.md](./docs/mask-syntax.md) for examples with ranges and edge cases.

## API

### `<NitroInputMask />`

Extends React Native's [`TextInputProps`](https://reactnative.dev/docs/textinput#props).

| Prop | Type | Required | Description |
|---|---|---|---|
| `mask` | `string` | ✓ | Mask pattern to apply |
| ...TextInputProps | | | All standard TextInput props |

### `NitroInputMaskService.applyMask(props)`

| Prop | Type | Description |
|---|---|---|
| `value` | `string` | The raw string to mask |
| `mask` | `string` | The mask pattern to apply |

Returns the masked `string`. Throws if `value` exceeds 1000 characters or `mask` exceeds 200 characters.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create your branch: `git checkout -b feat/your-feature`
3. Commit your changes following [Conventional Commits](https://www.conventionalcommits.org/)
4. Open a pull request

## License

MIT © [Salve Software](https://github.com/Salve-Software)
