# Money Mask

The `money` mask type formats numbers as currency values. It works right-to-left: digits are always pushed from the right, so typing `1`, `2`, `3` with precision `2` gives `0,01` → `0,12` → `1,23`.

## Usage

```tsx
<NitroInputMask
  maskType="money"
  maskOptions={{
    unit: 'R$ ',
    precision: 2,
    separator: ',',
    delimiter: '.',
  }}
  keyboardType="numeric"
/>
```

## Options

| Option | Type | Default | Description |
|---|---|---|---|
| `precision` | `number` | `2` | Number of decimal digits |
| `separator` | `string` | `','` | Decimal separator character |
| `delimiter` | `string` | `'.'` | Thousands separator character |
| `unit` | `string` | `''` | Prefix string (e.g. `'R$ '`, `'$ '`) |
| `suffixUnit` | `string` | `''` | Suffix string (e.g. `' USD'`) |
| `zeroCents` | `boolean` | `false` | When `true`, omits decimal part entirely |

## Examples

| Input digits | Options | Output |
|---|---|---|
| `123456` | default | `1,234.56` |
| `123456` | `unit: 'R$ '` | `R$ 1,234.56` |
| `123456` | `unit: '$'`, `separator: '.'`, `delimiter: ','` | `$1,234.56` |
| `123456` | `zeroCents: true` | `1,234` |
| `123456` | `precision: 0` | `123,456` |
| `5` | `unit: 'R$ '`, `precision: 2` | `R$ 0,05` |
