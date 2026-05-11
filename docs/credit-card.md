# Credit Card Mask

The `credit-card` mask type formats card numbers into groups according to the card issuer's standard layout. Optionally obfuscates all groups except the last.

## Usage

```tsx
<NitroInputMask
  maskType="credit-card"
  maskOptions={{ issuer: 'visa-or-mastercard' }}
  keyboardType="numeric"
/>
```

## Options

| Option | Type | Default | Description |
|---|---|---|---|
| `issuer` | `'visa-or-mastercard' \| 'amex' \| 'diners'` | `'visa-or-mastercard'` | Card issuer, determines the grouping pattern |
| `obfuscated` | `boolean` | `false` | Replaces digits in all but the last group with `*` |

## Grouping patterns

| Issuer | Pattern | Example |
|---|---|---|
| `visa-or-mastercard` | `9999 9999 9999 9999` | `4111 1111 1111 1111` |
| `amex` | `9999 999999 99999` | `3782 822463 10005` |
| `diners` | `9999 999999 9999` | `3056 930902 5904` |

## Obfuscation

When `obfuscated: true`, all digit groups except the last are masked with `*`. Spaces are kept intact.

```
4111 1111 1111 1111  →  **** **** **** 1111
3782 822463 10005    →  **** ****** 10005
```

Useful for displaying a saved card number while keeping the full value in state.
